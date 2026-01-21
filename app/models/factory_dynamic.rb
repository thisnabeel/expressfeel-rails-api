class FactoryDynamic < ActiveRecord::Base
    
    belongs_to :factory
    serialize :english_instructions, coder: JSON
    serialize :original_instructions, coder: JSON
    serialize :roman_instructions, coder: JSON
    # has_many :parameters, class_name: "FactoryDynamicParameters"
    has_many :factory_dynamic_parameters
    has_many :factory_dynamic_inputs
    has_many :factory_dynamic_outputs, through: :factory_dynamic_inputs
    has_many :dynamic_rules
    
    alias_attribute :parameters, :factory_dynamic_parameters

    @@instructions = []
    @@factory_material = nil
    @@permute_material = nil

    def build(funnels = nil)
        # Initialize funnels hash if not provided
        funnels ||= {}
        
        # For each factory_dynamic_input, if it doesn't have a locked material (funnel),
        # randomly sample one
            self.factory_dynamic_inputs.each do |fdi|
            unless funnels[fdi.slug].present?
                funnels[fdi.slug] = {
                    "factory_material" => FactoryMaterialSerializer.new(fdi.factory.factory_materials.sample).as_json
                }
            end
        end

        return FactoryDynamicService.new(config: self.flow_config, inputs: [], funnels: funnels, outputs: self.factory_dynamic_outputs).run
    end

    def permute
        hash = {}
        self.parameters.each do |param|
            hash[param.material_name.downcase] = self.factory.language.factories.find_by(materials_title: param.material_name.downcase).factory_materials
        end
        puts "permuting this #{hash}"
        return hash
    end

    def self.build(size)
        output = []
        Reaction.all.sample(size).each do |c|
            lang = c.factory
            material = lang.factory_materials.sample.id
            output.push(c.build(material))
        end
        return output
    end

    def test
        factory = self.factory
        language = self.factory.language
        
        # if 
        if !@@factory_material.present?
            # puts "Factory Material is NOT present"
            materials = factory.factory_materials
            @@factory_material = materials.sample

            # puts @@factory_material.attributes
            # TODO: make it work with more parameters
            @@permute_material = {}
            self.parameters.pluck(:material_name).each {|name| 
                @@permute_material[name] = language.factories.find_by(name: name).factory_materials.sample
            }
            puts "THE PARAMS NOW: #{@@permute_material}"
        end

        # if self.
        # end

        hash = {}
        english, roman, original = ["", "", ""]

        english_instructions = self.english_instructions
        original_instructions = self.original_instructions
        roman_instructions = self.roman_instructions
        
        hash = {
            english: polished("", english_instructions),
            original: polished("", original_instructions),
            roman: polished("", roman_instructions),
            # materials: @@permute_material
        }

        hash


    end

    def quiz
        inputs = self.accepted_inputs.filter {|f| f["name"].present?}.map {|i| i["name"].capitalize}
        language = self.factory.language
        factory_materials_by_type = language.factories.filter{|f| inputs.include? f.materialable_type }.map {|f| f.factory_materials}.flatten.group_by(&:materialable_type)
        
        # Generate all permutations of combinations
        permutations = factory_materials_by_type.values.reduce(&:product).map { |combination| Hash[factory_materials_by_type.keys.zip(combination)] }
        
        permutations = permutations.map { |combination| combination.map {|key, value| [key.singularize.downcase, value] }.to_h} 
        
        permutations_range = 4
        permutations = permutations.shuffle.first(permutations_range)
        answer_items = permutations.pop
        remaining_permutations = permutations

        options = {
            language: language,
            items: answer_items,
            dynamic: self
        }
        built = DynamicBuilder.build(options)
        outputs = built[:outputs]
        puts outputs

  

        other_outputs_sets = []

        remaining_permutations.each do |items|
            options = {
                language: language,
                items: items,
                dynamic: self
            }
            begin 
                other_outputs_sets << DynamicBuilder.build(options)[:outputs]
            rescue
            end
        end
        # return other_outputs_sets     
        
        pairs = find_quizzable_pairs(outputs)
        challenge = pairs.sample

        quiz_export = {
            roman: "",
            roman_blocks: [],
            direction: language.direction,
            tags: [],
            meta: [],
            solutions: {
                original: [],
                roman: []
            },
            original_blocks: []
        }
        challenge.each do |c|
            k = c.split("_").last
            val = outputs[c]
            quiz_export[k] = val
            quiz_export[:solutions][:original] = [outputs[c]] if k === "original"
        end

        challenge.each do |c|
            k = c.split("_").last
            val = outputs[c]
            quiz_export[k] = val
        end

        quiz_export[:original_blocks] << quiz_export["original"].split(" ").uniq.shuffle

        other_outputs_sets.each do |set|
            challenge.filter{|e| e.end_with? "original"}.each do |c|
                k = c.split("_").last
                val = set[c]
                puts "@@@ #{c} -> #{val}"
                val.split(" ").each {|block| quiz_export[:original_blocks] << block}
            end
        end

        quiz_export[:original_blocks] = quiz_export[:original_blocks].flatten.uniq.shuffle

        return quiz_export
        

        # return {
        #     original: original,
        #     original_blocks: original_blocks.uniq.shuffle,
        #     direction: direction,
        #     english: english,
        #     roman: roman.downcase,
        #     roman_blocks: roman_blocks.uniq.shuffle,
        #     tags: tags,
        #     meta: main[:meta],
        #     solutions: solutions(main)
        # }

    end

    def find_quizzable_pairs(data)
        original_keys = data.keys.select { |key| key.end_with?("_original") }
        pairs = original_keys.map do |original_key|
            english_key = original_key.sub("_original", "_english")
            [original_key, english_key] if data.key?(english_key)
        end.compact
    end





    def build_vi(factory_material_id = nil, params = nil)

        if !factory_material_id && !params
            return self.test
        end


        factory = self.factory
        language = self.factory.language

        @@permute_material = params

        
        if factory_material_id.present?
            factory_material = FactoryMaterial.find(factory_material_id)
            english_material = factory_material.materialable
            puts "factory_material_id is present: #{factory_material_id}: #{factory_material.attributes}"
        else
            puts "factory_material_id is NOT present"
            factory_material = getMaterials(self).sample
            english_material = factory_material.materialable
        end

        puts "today we will build: #{factory_material_id} & params: #{params}"

        @@factory_material = factory_material
        
        hash = {}


        english, roman, original = ["", "", ""]

        english_instructions = self.english_instructions
        original_instructions = self.original_instructions
        roman_instructions = self.roman_instructions
        
        
        hash = {
            english: polished("", english_instructions),
            original: polished("", original_instructions),
            roman: polished("", roman_instructions),
        }

        puts "MADEE"
        puts "host: #{@@factory_material.folder}"
        puts "params: #{@@permute_material}"
        puts hash
        hash

    end

    def self.roots(options)
        roots = options[:roots].split("")
        placeholder = options[:placeholder].split("")
        output = options[:formula]
        placeholder.each_with_index do |p, index| 
            output = output.gsub(p, roots[index])
        end
        return output
    end

    def steps
        return organize_dynamic_rules(self.dynamic_rules.order("position ASC"))
    end

    private

    def getMaterials(dynamic)
        return dynamic.factory.factory_materials
    end

    def polished(word, instructions)
        puts "THIS IS THE INSTRUCTION OBJECT ______ #{instructions}"
        c_present = false
        return word if !instructions.present?
        instructions.each do |instruction|
            puts "CONDITIONS : #{instruction["conditions"]}"
            puts "NO CONDITIONS"; break if !instruction["conditions"].present?
            c_present = true

            instruction["conditions"].each do |condition|
                puts "--------------------"
                puts "CONDITION FOUND"
                puts condition

                passing = true
                passing = passing? @@factory_material.folder, condition["ifs"] if condition["ifs"].present?

                if passing
                    puts "Applying Thens"
                    word = morpher word, condition["thens"] if condition["thens"].present?
                else
                    puts "Applying Elses"
                    word = morpher word, condition["elses"] if condition["elses"].present?
                end


                puts "--------------------"
            end
        end

        return word
    end

    def passing? specimen, statements
        puts 'IF STATMENTS'
        puts "--- Passing the specimen: #{specimen}"
        puts "There are #{statements.count} specimens"
        # bool = true

        statements.each_with_index do |statement, index|
            puts "Testing Specimen ##{index}"
            puts "With params: #{@@permute_material}"
            return false if ConditionChecker.test(specimen, statement, @@permute_material) === false
        end
        # return bool
        return true
    end

    def morpher word, list
        list.try(:each) do |obj|
            puts "BEFORE: #{word}"
            puts "~~~~"
            puts "#{obj["rule"]} #{obj["value"]}"
            case obj["rule"]
            when "delete_prefix"
                if (obj["value"].to_i.to_s == obj["value"])
                    i = obj["value"].to_i
                    word = word[i..-1]
                else
                    word = word.delete_prefix(obj["value"])
                end
            when "delete_suffix"
                if (obj["value"].to_i.to_s == obj["value"])
                    i = obj["value"].to_i
                    position = word.length - i
                    word = word[0..(position - 1)]
                else
                    word = word.delete_suffix(obj["value"])
                end

            when "add_prefix"
                word = obj["value"] + word

            when "add_suffix"
                if obj["value"].include? "~"
                    dynaAttr = obj["value"][/~(.*?)~/, 1]
                    puts "$$$$ dyno #{dynaAttr}"

                    if dynaAttr.start_with? "eng:"
						engObj = @@factory_material.materialable
                        string = engObj[dynaAttr.split("eng:")[1].to_sym]
                    else
                        string = @@factory_material.folder[dynaAttr]
                    end

                    word = word + string
                else

                    word = word + obj["value"]
                end

            when "replace_prefix"
                this = obj["value"].split(", ")[0]
                that = obj["value"].split(", ")[1]

                if that == "''"
                    that = ""
                end
                word = that + word.delete_prefix(this)

            when "replace_suffix"
                this = obj["value"].split(", ")[0]
                that = obj["value"].split(", ")[1]

                if that == "''"
                    that = ""
                end
                word = word.delete_suffix(this) + that
            when "flip_prefix"
                range = obj["value"].to_i
                word = word[0..range].reverse + word[(range+1)..-1]
            when "flip_suffix"
                range = obj["value"].to_i
                position = word.length - range
                word = word[0..(position-1)] + word[position..-1].reverse
            when "add_dynamic"
                dynamic = FactoryDynamic.find(obj["value"].split("|")[0])
                cat = obj["value"].split("|")[1]
                puts "THE DYNA MATEIRAL WE NEED: #{@@factory_material.id} with the dynamic: #{dynamic.title}"
                word = word + dynamic.build(@@factory_material.id)[cat.to_sym]
            else
                break
            end
            
            puts "AFTER: #{word}"
            puts "########"
        end
        return word
    end

    def material(param)
        param.capitalize.singularize.constantize
    end



    def organize_dynamic_rules(dynamic_rules, parent_id = nil)

        # Filter dynamic_rules based on the current parent ID
        filtered_dynamic_rules = dynamic_rules.select { |dynamic_rule| dynamic_rule.dynamic_rule_id == parent_id }

        # Recursively organize children for each filtered dynamic_rule
        organized_children = filtered_dynamic_rules.map do |parent_dynamic_rule|
            children = organize_dynamic_rules(dynamic_rules, parent_dynamic_rule.id)
            { **parent_dynamic_rule.attributes.symbolize_keys, children: children }
        end

        organized_children

    end
end
