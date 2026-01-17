class Phrase < ActiveRecord::Base
	belongs_to :lesson
	belongs_to :language
	# has_many :phrases
  	has_many :missions
	after_create :init_position
	has_many :phrase_dynamics, dependent: :destroy
	has_many :phrase_factories, dependent: :destroy

	has_many :phrase_inputs, dependent: :destroy
	has_many :phrase_input_payloads, as: :payloadable
	has_many :phrase_orderings

	has_one :phrase_word_bank, dependent: :destroy

	has_many :word_block_phrases, dependent: :destroy
	has_many :word_blocks, through: :word_block_phrases

	# Phrase.all.each do |phrase|
	# 	begin 
	# 		phrase.inspect
	# 	rescue => error
	# 		puts "#{phrase.id} : #{error}"
	# 	end
	# end


	include PgSearch::Model
	# pg_search_scope :like,
    #               against: [:title, :translit],
	# 			  using: :trigram
				  
    pg_search_scope :search,
                  against: [:title, :translit],
                  using: {
                    tsearch: {},
                    trigram: {}
				  }
				  

	def init_position
		if self.lesson.phrases.where(language_id: self.language_id).count == 1
			self.update(position: 1)
		else
			position = self
			.lesson
			.phrases
			.where(language_id: self.language_id)
			.count
			self.update(position: position)
		end
	end

	def siblings
		language_id = self.language_id
		# binding.pry
		mainEnglish = self.formula["english"].map{|o| o["uuid"] = 0; o}

		array = []
		self.lesson.phrases.where(language_id: language_id).each do |p|
			thisEnglish = p.formula["english"].map{|o| o["uuid"] = 0; o}
			if mainEnglish === thisEnglish
				array.push(p.id)
			end
		end

		return Phrase.find(array)
	end
	
	def self.most_populated
		Lesson.find(Phrase.where(ready: true).map {|p| p.lesson_id}).count
	end

	def find_concepts
		if self.tags.present?
			tags = self.tags.split(", ")
			traits = []
			tags.each do |t|
				trait = Trait.where('unaccent(tags) ILIKE ?', "%#{t}%")
				trait.each do |t|
					traits.push(t)
				end
			end
			return traits
		else 
			return []
		end
	end

	def get_media
		require 'nokogiri'
		if self.missions.where.not(video: nil).present?
			
			return self.missions.where.not(video: nil).sample.video

		else
			
			return nil

		end
	end

	def family
		return self.lesson.phrases.where(language_id: self.language_id)
	end

	def blocks
		begin 
			return sanitize(self.title)
				.split(" ").reject { |block| block.include?("؟") || block.include?("_") || block.include?("?") || block.include?("[")}
		rescue
			return []
		end
	end

	def puzzle
		blocks = self.blocks
		self.language.phrases.sample(3)
			.reject {|phrase| phrase.id == 62}.each {|phrase| phrase.blocks.each {|p| blocks << p } }
		return blocks.uniq.shuffle
	end

	def sanitized
		sanitize(self.title)
	end

	def self.populated
		return Phrase.where.not(title:[nil, "<p><br></p"])
	end

	# 

	def buildOld
		extract_list = ["original", "roman", "english"]

		dynamics = []

		output = {
			original: [], 
			roman: [], 
			english: [],
		}

		puts "formulllaa"
		# puts self.formula

		extract_list.each do |key|
			puts "-----------------"
			puts "MAKING KEY #{key}"
			# puts self.formula


			
			unless self.formula[key].present?
				output[key] = ["Nothing Found"]
				next
			end
			
			# This is where a blocks POSSIBILITIES are collected
			block_list = []
			origs = []
			newOrig = ""

			catBlocks = self.formula[key]
			blocksStatus = Array.new(catBlocks.count, nil)

			puts "There are #{catBlocks.count} blocks"
			puts "#{catBlocks.map {|block| 
				if block["material"] 
					"#{block["material"]}:#{block["attribute"]}" 
				else
					block[:body]
				end
			}}"
			puts "Status: #{blocksStatus}"
			puts "-----------------"

			puts "catblocks"
			puts catBlocks

			# For each Formula Block
			i = 0
			while blocksStatus.any? nil
				puts "loop: #{i}"
				break if i > blocksStatus.length

				blocksStatus.each_with_index do |status, idx|
					block = catBlocks[idx]

						i += 1

						next if status.present?
						
						# Check if the block has a MATERIAL:ATTRIBUTE
						if block["material"].present? && block["attribute"]
							
							# Save the Material
							materialsTitle = block["material"]
							languageId = self.language_id

							# Find the Material's Factory
							factory = Factory.find_by(
								materials_title: materialsTitle, 
								language_id: languageId
							)

							if factory.present?
								# Get the Factory Materials
								if factory.factory_materials.present?

									collection = []
									semiDynamics = []

									factory.factory_materials.each do |material|
										if block["attribute"].start_with? "eng:"
											puts "#{block["attribute"]} is english material"
											attribute = block["attribute"].split(":")[1]
											engObj = material.materialable
											blocksStatus[idx] = material
											if engObj.present?
												collection.push(engObj[attribute.to_sym])
												semiDynamics.push({
													# object: engObj,
													title: "eng:" + attribute,
													item: engObj[attribute.to_sym]
												})
											else
												collection.push("nil")
											end
										elsif block["attribute"].start_with? "**"

											# pronouns -> **roman:noun_possession

											puts "#{block["attribute"]} is dynamic material"
											# **roman:noun_possession

											# Cat is [original,roman,english]
											cat = block["attribute"].split("**")[1].split(":")[0]
											
											# attribute is [:noun_posession]
											attribute = block["attribute"].split(":")[1]

											# this makes the dynamic
											next if !block[:link].present?
											param = blocksStatus[block[:link]]
											if param === nil
												next;
											end

											puts "&&&&&&"
											puts "TRYING THE MATERIAL: #{material}"
											# first part needs to be the host, last part needs to be params
											params = paramify([param]);
											dyna = material.dynamic(attribute, cat, params)

											blocksStatus[idx] = dyna;

											collection.push(dyna)
												semiDynamics.push({
													# object: engObj,
													title: "original:"+"#{materialsTitle}:**"+cat+":"+attribute,
													item: dyna
												})
										else
											puts "#{block["attribute"]} is original material"

											blocksStatus[idx] = material;

											collection.push(material.folder[block["attribute"]])
											semiDynamics.push({
													# object: material,
													title: "original:"+"#{materialsTitle}:"+block["attribute"],
													item: material.folder[block["attribute"]]
												})
										end
									end
									puts "Collection is: #{collection}"
									puts "SemiDynamics is: #{semiDynamics}"
									block_list.push(collection)
									dynamics.push(semiDynamics)
								end
							end
						else
							# IF IT'S NOT DYNAMIC
							blocksStatus[idx] = block["body"] || "err";
							block_list.push([block["body"] || "err"])
						end
						puts "Blocks Status: #{blocksStatus}"
						# puts "BLOCK LIST: #{block_list}"
					
				end
			end
			

			
			i = 0
			# keep making new ones till they are all unique
			while (origs.length - origs.uniq.length) < 2
				newOrig = ""
				block_list.each do |block_set|
					begin
						block_set[i].present? ? newOrig += block_set[i] : newOrig += block_set[block_set.length - 1] 
					rescue => err
						puts err
					end
				end
				origs.push(newOrig)
				i += 1
			end

			origs.push(newOrig)

			output[key] = origs.uniq
			output[:dynamics] = transform_hash(dynamics)
		end

			puts "___+_+_+_+_ MAAADE"
			puts output
			puts "______+_+_+_+"

		return output
		# return 
	end


	

	def ready_recipes
		dynamics = []

		category_blocks = {
			original: self.formula["original"], 
			roman: self.formula["roman"], 
			english: self.formula["english"], 
		}

		ingredients = {}

		languageId = self.language_id

		recipes = {}

		# FOR [original, roman, english] BLOCKS list					
		category_blocks.each do |category, blocks|

			# initiate the ingredients
			ingredients[category] = []

			# initiate what to do with the ingredients
			instructions = []

			# container for final output
			recipes[category] = {}
			next if !blocks.present?
			
			
			blocks.each do |block|
				# IF THE BLOCK IS A MATERIAL
				if block["material"] && block["attribute"]
					materialsTitle = block["material"]
					factory = Factory.find_by(
								materials_title: materialsTitle, 
								language_id: languageId
							)
					
					# If block is NOT linking
					if !block[:link].present?
						# GET ALL THE MATERIALS
						listItem = factory.factory_materials.to_a
					else
						puts "The Block/ListItem is LINKING, listItem is nil #{block}"
						# 
						listItem = [nil]
					end

					instr = {
						attribute: block["attribute"],
						link: block[:link] || nil
					}
					# If the block is a HOSTER
					if (is_hoster(block))
						# puts "-----------"
						# puts "The Block/ListItem is HOSTER, listItem is nil #{block.reject { |k, v| k == "uuid" }}"
						# puts "The GUEST is #{blocks[block[:link]].reject { |k, v| k == "uuid" }}"
						# puts "Since this is a HOSTING situation we do not need a Specific Material."
						# puts "So, the #{block["material"]}:#{block["attribute"]} dynamic will build with the provided #{blocks[block[:link]][:material]}:#{blocks[block[:link]][:attribute]}"
						# puts "->>>"
						# puts "#{block["material"]}:#{block["attribute"]}(#{blocks[block[:link]][:material]}:#{blocks[block[:link]][:attribute]})"
						instr[:material] = "host"
						listItem = factory.factory_materials.to_a
						# puts "the list items are #{listItem}"
						# puts "-----------"
					end
					instructions.push(instr)
				else
					listItem = [block["body"]]
					instructions.push(nil)
				end
				ingredients[category].push(listItem)
			end
			
			recipes[category][:instructions] = instructions
			if ingredients[category].length < 2
				recipes[category][:combos] = ingredients[category]
			else
				recipes[category][:combos] = all_combinations(ingredients[category])
			end
		end

		# return recipes
		output = recipes[:original][:combos].each_with_index.map do |element, index|
  			{ 
				original: {
					instructions: recipes[:original][:instructions],
					combo: element,
				}, 
				roman: {
					instructions: recipes&.dig(:roman, :instructions) || [],
					combo: recipes&.dig(:roman, :combos, index) || []
				}, 
				english: {
					instructions: recipes[:english][:instructions],
					combo: recipes[:english][:combos][index]  || []
				}
			}
		end

		return output
		# return showWiring(output)
		# ->[].map {|c| c.first[:combo]}
	end

	# 
	def build_step(list)
		materials = self.language.factory_materials
		payload = {}
		list.each do |item|
			up_key = item.class.name.singularize
			down_key = up_key.downcase
			material = materials.find_by(materialable_type: up_key, materialable_id: item.id)
			code = self.phrase_inputs.find { |pi| pi.code.start_with?(down_key) }&.code
			if code.present?
				hash = {
						language_material: material,
						english_material: material.materialable
					}
				payload[code] = hash
				
			end
		end
		return self.build(payload)
	end

	def build(payload={})
		language = self.language
		phrase_dynamics = self.phrase_dynamics.order("position ASC")
		catalog = build_catalog(language, phrase_dynamics)
		material_selections = {}
		exports = {}
		category_output = {}
		factories = self.phrase_factories.includes(factory: [:factory_materials]) 

		# phrase_inputs - Load all at once, ordered by id
		phrase_inputs = self.phrase_inputs.order("id ASC").to_a
		phrase_items = {}
		
		# Pre-load permits for all phrase_inputs to avoid N+1
		permit_data_by_input_id = {}
		phrase_inputs.each do |pi|
			permits = pi.phrase_input_permits.select { |p| p.permit == true }
			permit_data_by_input_id[pi.id] = {
				material_tag_option_ids: permits.map(&:material_tag_option_id).compact,
				factory_material_ids: permits.map(&:factory_material_id).compact
			}
		end
		
		phrase_inputs.each do |pi|
			if pi.phrase_inputable_type === "Factory"
				if payload[pi.code]
					hash = payload[pi.code]
				else
					materials = nil
					permit_data = permit_data_by_input_id[pi.id]
					
					if permit_data && (permit_data[:material_tag_option_ids].any? || permit_data[:factory_material_ids].any?)
						# Use eager-loaded associations
						all_materials = pi.phrase_inputable.factory_materials.to_a
						
						# Filter by material_tag_option_id using in-memory filtering
						if permit_data[:material_tag_option_ids].any?
							materials = all_materials.select do |fm|
								fm.material_tags.any? { |mt| permit_data[:material_tag_option_ids].include?(mt.material_tag_option_id) }
							end.uniq
						else
							materials = []
						end
						
						# Add materials by id
						if permit_data[:factory_material_ids].any?
							additional_materials = all_materials.select { |fm| permit_data[:factory_material_ids].include?(fm.id) }
							materials = (materials + additional_materials).uniq
						end
					else
						materials = pi.phrase_inputable.factory_materials.to_a
					end

					material = materials.sample
					hash = {
						language_material: material,
						english_material: material.materialable
					}
				end
				exports[pi.code] = hash
				phrase_items[pi.code] = hash
			end

			if pi.phrase_inputable_type === "FactoryDynamic"
				dynamic = pi.phrase_inputable
				input_materials = {}
				pi.phrase_input_payloads.each do |payload_item|
					# Use eager-loaded associations
					slug = payload_item.payloadable&.slug
					code = payload_item.code
					if slug && code
						input_materials[slug] = phrase_items[code]
					end
				end

				phrase_items[pi.code] = {
					input_materials: input_materials, 
					built: dynamic.build(input_materials.map { |key, item| 
						[key, {"factory_material" => FactoryMaterialSerializer.new(item[:language_material]).as_json}] 
					}.to_h)
				}
				exports[pi.code] = phrase_items[pi.code]
			end

			if pi.phrase_inputable_type === "Phrase"
				input_phrase = pi.phrase_inputable
				# Use eager-loaded associations
				nested_payload = pi.phrase_input_payloads.each_with_object({}) do |pip, hash|
					code = pip.payloadable&.code
					if code && phrase_items[code]
						hash[code] = phrase_items[code]
					end
				end
				built = input_phrase.build(nested_payload)

				# Merge nested exports into current exports
				if built[:exports]
					exports.merge!(built[:exports]) { |key, oldval, newval| oldval } # Prefer outer values if duplicate
				end

				phrase_items[pi.code] = {
					input_materials: {},
					built: built
				}

				# Also register the nested phrase as its own export if needed
				exports[pi.code] = phrase_items[pi.code]
			end

		end

		# Must process original first
		category_output[:orderings] = {original: [], roman: []}
		category_output[:solutions] = {original: [], roman: []}
		output_blocks_by_category = {}
		
		[:original, :roman, :english].each do |category|
			blocks = self.formula[category.to_s]
			output_blocks = build_category_output(blocks, catalog, self.language_id, material_selections, category, phrase_items, factories)
			
			if output_blocks.present?
				category_output[:block_outputs] ||= {}
				category_output[:block_outputs][category] = output_blocks.dup
				category_output[category] = output_blocks.join
				output_blocks_by_category[category] = output_blocks
			else
				category_output[category] = ""
			end
		end

		# Process phrase_orderings and apply to both original and roman
		# Pre-load all orderings once instead of querying inside the loop
		all_orderings = self.phrase_orderings.to_a
		[:original, :roman].each do |category|
			if output_blocks_by_category[category].present?
				# Filter in-memory instead of querying
				orderings = all_orderings.select { |o| o.category.nil? || o.category == category.to_s }
				orderings.each do |ordering|
					reordered_blocks = ordering.line.map do |item|
						output_blocks_by_category[category][item["ref_index"]]
					end
					category_output[:orderings][category] << reordered_blocks
				end
			end
		end

		# Build solutions from orderings
		[:original, :roman].each do |category|
			if category_output[:solutions].keys.include?(category)
				category_output[:solutions][category] = ([category_output[category]] + category_output[:orderings][category].map{|reordered| reordered.join}).uniq
			end
		end

		category_output[:exports] = exports

		populate_word_bank(category_output)

		category_output
	end
		
	
	private
	
	def populate_word_bank(category_output)
		bank_words = (category_output[:original].split + category_output[:roman].split)
		bank_words.uniq

		bank = PhraseWordBank.find_or_create_by(phrase_id: self.id)
		bank.update(words: (bank.words + bank_words).uniq)
	end
	
	def build_catalog(language, phrase_dynamics)
		phrase_dynamics.each_with_object({}) do |pd, catalog|
			options = {
				language: language,
				items_manifest: pd.input_selections,
				dynamic: pd.factory_dynamic
			}
			catalog[pd.id] = DynamicBuilder.build(options)
		end
	end

	def build_category_output(blocks, catalog, language_id, material_selections, category, exports, factories)
		return "" unless blocks.present?
		blocks.map do |block|
			padding_left = block["padding_left"] ? " " : ""
			padding_right = block["padding_right"] ? " " : ""
			output = PhraseBlockResolver.resolve(self, block, catalog, language_id, material_selections, category, exports, factories).to_s
			padding_left + output + padding_right
		end
	end


	def extract_category_blocks(formula)
		{
			original: formula['original'],
			roman: formula['roman'],
			english: formula['english'],
		}
	end

	def buildCombo(combo, instructions)
		return {
					dynamics: [],
					phrase: "err-eng combo problem"
				} if !combo.present?
		string = ""
		semidynamics = []


		combo.each_with_index do |block, index|
			puts "PUTTING BLOCK this: #{block.class.name}: #{block}"
			instr = instructions[index]
			puts "with instr: #{instr}"

			if (block.is_a? NilClass) && (instr[:link].present?)
				if (instr[:attribute].start_with? "**")
				else
					block = combo[instr[:link]]
				end
			end


			# If block is a stand-alone Material
			if block.is_a? FactoryMaterial 
				selfBlock = block
				puts "building factorymaterial: #{block}"
				# puts "IIII"
				# puts "BLOCK: #{block.folder} #{instr}"
				puts "INSTR: #{instr} "
				puts "BLOCK: #{block} "
				puts "#{index}"
				puts "#{instructions}"
				next if !instr.present?

				attribute = instr[:attribute]
				
				if attribute.present?

					if attribute.start_with? "eng:"
						engObj = block.materialable
						puts engObj.attributes
						puts "-> #{attribute.split("eng:")[1]}"

						instr = engObj[attribute.split("eng:")[1].to_sym]
					
						string += instr

						attribute = engObj.class.name.pluralize.downcase + ":" + attribute

					elsif (instr[:link].present?) && (instr[:attribute].start_with? "**")

						attribute = instr[:attribute]
						link = instr[:link]
						if instr[:material] === "host"
							block = selfBlock
						else
							block = instr[:material]
						end
						# Hoster, requires Guest
						if attribute.start_with? "**"
							category, key = attribute.split("**")[1].split(":")

							params = paramify(
								[
									combo[instr[:link]]
								]
							)
							puts "putting paramsss"
							puts params

							puts "with block #{block}"

							puts "tryna DYNA #{block.materialable_type}"
							instr = block.dynamic(key, category, 
								params
							)

							string += instr

							attribute = block.materialable_type.pluralize.downcase + ":**" + attribute.split("**")[1]
						end

					
					else

						instr = block.folder[attribute]
						
						string += instr || ""


						attribute = block.materialable_type.pluralize.downcase + ":" + attribute


					end

					semidynamics.push({
						attribute: attribute,
						item: instr
					})
				end	

			# This means its a LINKER
			elsif if (block.is_a? NilClass) && (instr[:link].present?)
				attribute = instr[:attribute]
				link = instr[:link]
				block = instr[:material]
				# Hoster, requires Guest
				if attribute.start_with? "**"
					category, key = attribute.split("**")[1].split(":")
					# string += link.to_s + "'s #{category}:#{key}"
					params = paramify(
						[
							combo[instr[:link]]
						]
					)
					puts "putting paramsss"
					puts params

					puts "tryna DYNA #{block.materialable_type}"
					instr = block.dynamic(key, category, 
						params
					)

					string += instr


					attribute = block.materialable_type.pluralize.downcase + ":**" + attribute.split("**")[1]

				end

				semidynamics.push({
					attribute: attribute,
					item: instr
				})
			end
				
			# If block is JUST a String
			elsif block.is_a? String
				puts "putting #{block}"
				string += block
			end
		end
		return {
					dynamics: semidynamics,
					phrase: string
				}
	end

	def all_combinations(arrays)
  		arrays.reduce(&:product).map(&:flatten)
	end

	def sanitize(title)
		return title
				.gsub("?", '')
				.gsub("؟", '')
				.gsub(".", '')
				.gsub('¿', '')
	end

	def paramify(params)
		hash = {}
		params.each do |p|
			hash[p.materialable_type.pluralize.downcase] = p
		end
		return hash
	end

	def transform_hash(arrays)

		output = []
		i = 0
		stillGoing = true
		while i <= arrays.count
			semiOut = []
			arrays.each do |array|
				semiOut.push(array[i])
			end
			output.push(semiOut)
			i += 1
		end

		return output.select{|obj| obj[0] != nil}
		# result = { dynamics: [] }

		# original = input_hash[0]
		# roman = input_hash[:dynamics][1]
		# english = input_hash[:dynamics][2]

		# original_category = original[0][:title].split(":")[1..-1].join(":")
		# roman_category = roman[0][:title].split(":")[1..-1].join(":")
		# english_category = english[0][:title].split(":")[0..1].join(":")
		
		# # Add the new hash to the result
		# result[:dynamics] << {
		# 	original: sanitize(original[0][:item]),
		# 	roman: sanitize(roman[0][:item]),
		# 	english: sanitize(english[0][:item]),
		# 	originalCategory: original_category,
		# 	romanCategory: roman_category,
		# 	englishCategory: english_category,
		# 	category: original_category.split(":")[0]
		# }
		
		# result
	end

	def is_hoster(block)
		return (block[:link].present?) && (block["attribute"].start_with? "**")
	end

	def showWiring(array)
		return array.map {|s| 
			s.map {|cat, k| 
				{
					category: cat,
					instructions: k[:instructions],
					combo: k[:combo].map {|j| 
						j.class.name === "FactoryMaterial" ? "#{j.materialable_type}:#{j.id}" : j
						
					}
				}
			}
			# s[:combo].map {|j| 
			# 	j.class.name === "FactoryMaterial" ? "#{j.materialable_type}:#{j.id}" : j
			# }
		}
	end
end