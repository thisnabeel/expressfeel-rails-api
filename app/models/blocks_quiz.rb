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

                built.each do |item|
                    next if !item[:original].present? && !item[:english].present?
                    hash = {
                        siblings: phrase.siblings,
                        original: item[:original],
                        english: item[:english],
                        tags: "",
                    } 

                    if item[:roman].present?
                        hash[:roman] = item[:roman]
                    end
                    options.push(hash)
                end

                options = options.reject { |obj| obj[:english].include?("err-") }

                options = options.shuffle
                main = options[0]
                direction = phrase.language.direction

                tags = ""

                meta = {}

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

            options = options.shuffle

            original = sanitizedBlocks(main[:original]).join(" ")
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
            return string.split(" ")
                .map{|block| 
                    block
                }
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

            list = {
                original: [main[:original]],
                roman: [main[:roman]]
            }

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
