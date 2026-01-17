class BlocksQuiz < ApplicationRecord
    class << self
        def make(object = nil)
            puts "_+_+_+ BUILDING A QUIZ"

            return object unless object.present?

            options = []

            case object.class.name
            when "Reaction"

                puts "_+_+_+ BUILDING QUIZ USING A REACTION"

                reaction = object
                factory = object.factory
                materials = factory.factory_materials
                
                materials.sample(3).each do |material|
                    built = reaction.build(material)
                    options.push({
                        original: built["original"],
                        english: built["english"],
                        roman: built["roman"],
                        tags: built["tags"],
                        meta: built["meta"]
                    })
                end

                main = options[0]
                direction = factory.language.direction

                tags = ""



            when "Phrase"
                puts "_+_+_+ BUILDING QUIZ USING A PHRASE"

                phrase = object

                built = [phrase.build, phrase.build, phrase.build]
                puts "BUILD #{built}"

                # Get orderings from first built phrase
                built_phrase_with_orderings = built.first || phrase.build

                built.each do |item|
                    next if !item[:original].present? && !item[:english].present?
                    hash = {
                        siblings: phrase.siblings,
                        original: item[:original],
                        english: item[:english],
                        tags: "",
                        block_outputs: item[:block_outputs]
                    } 

                    if item[:roman].present?
                        hash[:roman] = item[:roman]
                    end
                    options.push(hash)
                    persist_word_blocks!(phrase, hash)
                end

                options = options.reject { |obj| obj[:english].include?("err-") }

                options = options.shuffle
                main = options[0]
                
                if main.nil? || options.empty?
                    raise "Failed to generate quiz options - no valid options after filtering"
                end
                
                direction = phrase.language.direction

                tags = ""

                meta = {}
                main[:orderings] = built_phrase_with_orderings[:orderings] if built_phrase_with_orderings.present?

            else
            end

            # conjugations = self.language.conjugations.sample(3)
            # options = []

            # conjugations.each do |conj|
            #     options.push(conj.build(self.id))
            # end
        
            # if conjugation.present?
            #     built = conjugation.build(self.id)
            #     options.push(built)
            #     main = built
            # else
            #     main = options[0]
            # end

            if main.nil?
                raise "Failed to generate quiz - main option is nil"
            end

            options = options.shuffle

            original = sanitizedBlocks(main[:original] || "").join(" ")
            puts 'debug'
            puts main
            english = main[:english]

            # Because Latin Languages can be skipped
            if main[:roman]
                roman = sanitizedBlocks(main[:roman]).join(" ")
            else
                roman = original
            end
            tags = main[:tags]

            original_blocks = []
            roman_blocks = []
            options.each do |option|
                puts option
                sanitizedBlocks(option[:original]).each_with_index do |o, index| 
                    # code = index.to_s
                    code = ""
                    original_blocks.push(o+code)
                end
                
                # Because Latin Languages can be skipped
                if option[:roman]
                    sanitizedBlocks(option[:roman]).each_with_index do |o, index| 
                        # code = index.to_s
                        code = ""
                        roman_blocks.push(o.downcase+code)
                    end
                else

                end
            end
            
            return {
                original: original,
                original_blocks: original_blocks.uniq.shuffle,
                direction: direction,
                english: english,
                roman: roman.downcase,
                roman_blocks: roman_blocks.uniq.shuffle,
                tags: tags,
                meta: main[:meta],
                solutions: solutions(main)
            }
        end
        private
        def sanitizedBlocks(string)
            return [] if string.nil?
            return string.split(" ")
                .map{|block| 
                    block
                }
        end

        def persist_word_blocks!(phrase, option)
            return unless phrase.is_a?(Phrase)

            block_outputs = option[:block_outputs] || {}
            original_blocks = normalized_block_array(block_outputs[:original]) || sanitizedBlocks(option[:original].to_s)
            roman_blocks = normalized_block_array(block_outputs[:roman]) || (option[:roman] ? sanitizedBlocks(option[:roman]) : [])
            english_blocks = normalized_block_array(block_outputs[:english]) || (option[:english] ? sanitizedBlocks(option[:english]) : [])

            original_blocks.each_with_index do |original_block, index|
                next if original_block.blank?

                roman_block = index < roman_blocks.length ? roman_blocks[index] : nil
                english_block = index < english_blocks.length ? english_blocks[index] : nil

                word_block = WordBlock.find_by(
                    language_id: phrase.language_id,
                    original: original_block,
                    roman: roman_block,
                    english: english_block
                )

                unless word_block
                    word_block = WordBlock.create!(
                        language: phrase.language,
                        original: original_block,
                        roman: roman_block,
                        english: english_block
                    )
                end

                WordBlockPhrase.find_or_create_by!(
                    word_block: word_block,
                    phrase: phrase
                )
            end
        end

        def normalized_block_array(blocks)
            return nil unless blocks.respond_to?(:map)
            blocks.map do |block|
                block.is_a?(String) ? block.strip : block.to_s.strip
            end
        end

        def sanitizedString(string)
            return string.strip.split(" ")
                .map{|block| 
                    block
                        .gsub("?", "")
                        .gsub("؟", "")
                }.join(" ").strip
        end

        # def makeStatic(str, list)
        #     puts "MAKE STATIC"
        #     puts list.to_a
        #     puts "______"
        #     list.each do |l|
        #         str = str.gsub(l[:item], "")
        #     end
        #     return str
        # end

        def makeStatic(phrase)
            hash = {}
            hit = phrase.formula.keys
            hit.each do |cat|
                list = []
                phrase.formula[cat].try(:each) do |item|
                    if item["material"].present?
                        if item["attribute"].present? && item["attribute"].include?("eng:")
                            list.push("["+item["attribute"]+"]")
                        else
                            list.push("[#{item["material"]}:#{item["attribute"]}]")
                        end
                    else
                        begin
                            
                            list.push(item["body"].strip)
                        rescue => exception
                            
                        else
                            
                        end
                    end
                end
                hash[cat.to_sym] = list.join(" ")
            end
            return hash
        end

        def solutions(main)

            puts "SOLUTION LANNNDND!"

            statics = main[:siblings].map {|s| makeStatic(s)}

            puts "solution"

            # Helper to clean spacing: remove double spaces and trim
            clean_spacing = lambda do |str|
                return "" unless str.present?
                str.strip.gsub(/\s+/, " ")
            end

            list = {
                original: [clean_spacing.call(main[:original])],
                roman: [clean_spacing.call(main[:roman])]
            }

            # Add orderings if present
            if main[:orderings].present?
                # Join each ordering array and add to solutions
                if main[:orderings][:original].present?
                    main[:orderings][:original].each do |reordered_blocks|
                        joined = clean_spacing.call(reordered_blocks.join(" "))
                        list[:original] << joined if joined.present?
                    end
                end
                
                if main[:orderings][:roman].present?
                    main[:orderings][:roman].each do |reordered_blocks|
                        joined = clean_spacing.call(reordered_blocks.join(" "))
                        list[:roman] << joined if joined.present?
                    end
                end
            end

            # Remove duplicates and ensure unique solutions
            list[:original] = list[:original].uniq.reject(&:blank?)
            list[:roman] = list[:roman].uniq.reject(&:blank?)

            # category, key = attribute.split("**")[1].split(":")


            # keys = ["original", "roman"]
            # statics.each do |static|
            #     static.each do |key, phrase|
            #         puts "THIS KEY: #{key}"
            #         next if key === :english
            #         next if !main[key.to_sym].present?
                    
            #         puts "~~~main"
            #         puts main
            #         puts key
            #         if main[key.to_sym] && main[key.to_sym][:dynamics].present?
            #             main[key.to_sym][:dynamics].each do |k|
            #                 next if !k.present?
            #                 phrase = phrase.gsub("[#{k[:attribute]}]", k[:item])
            #             end
            #         else
            #         end
            #         puts "PUTTiNG PHRASE"
            #         puts phrase
            #         puts list
            #         list[key.to_sym] << sanitizedString(phrase)
            #     end
            # end
            return list
        end
    end

end
