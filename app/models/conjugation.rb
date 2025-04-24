class Conjugation < ActiveRecord::Base

    belongs_to :language


    serialize :instructions, coder: JSON
    serialize :roman_instructions, coder: JSON

    @@instructions = []

    def self.build(size)
        output = []
        Conjugation.all.sample(size).each do |c|
            lang = c.language
            verb = lang.language_verbs.sample.id
            output.push(c.build(verb))
        end
        return output
    end

    def build(language_verb_id)
        language_verb = LanguageVerb.find(language_verb_id)
        @@language_verb = language_verb
        english_verb = language_verb.verb

        hash = {}

        english = ""
        roman = ""
        original =""

        original_instructions = self.instructions
        roman_instructions = self.roman_instructions
        
        self.english.match(/\(([^\)]+)\)/).try(:captures).try(:each) do |match|
            english = self.english.gsub("(#{match})", english_verb[match])
        end

        self.roman.match(/\(([^\)]+)\)/).try(:captures).try(:each) do |match|
            puts match
            puts language_verb.folder
            puts language_verb.folder[match]
            roman = self.roman.gsub("(#{match})", polished(language_verb.folder[match], roman_instructions))
        end

        self.original.match(/\(([^\)]+)\)/).try(:captures).try(:each) do |match|
            original = self.original.gsub("(#{match})", polished(language_verb.folder[match], original_instructions))
        end

        hash = {
            "english" => english,
            "original" => original,
            "roman" => roman,
            "tags" => self.tags,
            "meta" => {
                "language" => self.language,
                "conjugation_id" => self.id,
                "language_verb_id" => language_verb.id,
            }
        }
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

    # 
    def self.rebuild
        Conjugation.all.each do |c|
            c.rebuild
        end
    end



    def rebuild



        unless self.instructions.present? && self.instructions[0].present? && self.instructions[0]["title"].present?
            self.update(instructions: {
                "title" => "Default",
                "conditions" => [],
                "instructions" => self.instructions
            })
        end


        unless self.roman_instructions.present? && self.roman_instructions[0].present? && self.roman_instructions[0]["title"].present?
            self.update(roman_instructions: {
                "title" => "Default",
                "conditions" => [],
                "instructions" => self.roman_instructions
            })
        end
    end

    private
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
                passing = passing? @@language_verb.folder, condition["ifs"] if condition["ifs"].present?

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
        # sets.each do |set|
        #     next if !passing?((set["conditions"] || []), word, "")
        #     set["instructions"].try(:each) do |obj|
        #         puts "BEFORE: #{word}"
        #         puts "#{obj["style"]} #{obj["instruction"]}"
        #         case obj["style"]
        #         when "delete_prefix"
        #             if (obj["instruction"].to_i.to_s == obj["instruction"])
        #                 i = obj["instruction"].to_i
        #                 word = word[i..-1]
        #             else
        #                 word = word.delete_prefix(obj["instruction"])
        #             end
        #         when "delete_suffix"
        #             if (obj["instruction"].to_i.to_s == obj["instruction"])
        #                 i = obj["instruction"].to_i
        #                 position = word.length - i
        #                 word = word[0..(position - 1)]
        #             else
        #                 word = word.delete_suffix(obj["instruction"])
        #             end

        #         when "add_prefix"
        #             word = obj["instruction"] + word

        #         when "add_suffix"
        #             word = word + obj["instruction"]

        #         when "replace_prefix"
        #             this = obj["instruction"].split(", ")[0]
        #             that = obj["instruction"].split(", ")[1]

        #             if that == "''"
        #                 that = ""
        #             end
        #             word = that + word.delete_prefix(this)

        #         when "replace_suffix"
        #             this = obj["instruction"].split(", ")[0]
        #             that = obj["instruction"].split(", ")[1]

        #             if that == "''"
        #                 that = ""
        #             end
        #             word = word.delete_suffix(this) + that
        #         when "flip_prefix"
        #             range = obj["instruction"].to_i
        #             word = word[0..range].reverse + word[(range+1)..-1]
        #         when "flip_suffix"
        #             range = obj["instruction"].to_i
        #             position = word.length - range
        #             word = word[0..(position-1)] + word[position..-1].reverse
        #         else
        #             break
        #         end
                
        #         puts "AFTER: #{word}"
        #         puts "########"
        #     end
        # end

        # return word
    end

    def passing? specimen, statements
        puts 'IF STATMENTS'
        # bool = true

        statements.each do |statement|
            return ConditionChecker.test(specimen, statement)
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
                word = word + obj["value"]

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
            else
                break
            end
            
            puts "AFTER: #{word}"
            puts "########"
        end
        return word
    end
end
