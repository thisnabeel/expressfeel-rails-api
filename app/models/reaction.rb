class Reaction < ActiveRecord::Base

    belongs_to :machine


    serialize :instructions, coder: JSON
    serialize :roman_instructions, coder: JSON

    @@instructions = []

    def self.build(size)
        output = []
        Reaction.all.sample(size).each do |c|
            lang = c.factory
            material = lang.factory_materials.sample.id
            output.push(c.build(material))
        end
        return output
    end

    def build(factory_material_id = nil)
        
        if factory_material_id.present?
            factory_material = FactoryMaterial.find(factory_material_id)
            english_material = factory_material.materialable
        else
            factory_material = nil
            english_material = nil
        end

        language = self.machine.language

        @@factory_material = factory_material
        
        hash = {}

        english = self.english
        roman = self.roman
        original = self.original

        original_instructions = self.instructions
        roman_instructions = self.roman_instructions

        factory = nil

        possibilities = []
        
        
        self.english.match(/\(([^\)]+)\)/).try(:captures).try(:each) do |match|

            split = match.split(":")
            key = ""
            if split.count === 2
                name = split[0]
                key = split[1]
                factory = language.factories.where(name: name.capitalize || name).try(:first)
            end

            factory_material = factory.factory_materials.sample
            @@factory_material = factory_material

            english_material = factory_material.materialable

            if english_material.present?
                english = self.english.gsub("(#{match})", english_material[key])
            end
        end

        self.roman.match(/\(([^\)]+)\)/).try(:captures).try(:each) do |match|
            # puts match
            # puts factory_material.folder
            # puts factory_material.folder[match]
            split = match.split(":")
            key = ""
            if split.count === 2
                name = split[0]
                key = split[1]
            end



            if factory_material.present?
                roman = self.roman.gsub("(#{match})", polished(factory_material.folder[key], roman_instructions))
            end
        end

        self.original.match(/\(([^\)]+)\)/).try(:captures).try(:each) do |match|

            split = match.split(":")
            key = ""
            if split.count === 2
                name = split[0]
                key = split[1]
            end

            if factory_material.present?
                original = self.original.gsub("(#{match})", polished(factory_material.folder[key], original_instructions))
            end
        end


        hash = {
            "english" => english,
            "original" => original,
            "roman" => roman,
            "tags" => self.tags,
            "meta" => {
                "language" => language,
                "conjugation_id" => self.id,
                "factory_material" => factory_material.present? ? factory_material.id : nil,
                "possibilities" => possibilities
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
