class Fragment < ActiveRecord::Base

    belongs_to :language

    serialize :instructions, coder: JSON
    serialize :roman_instructions, coder: JSON

    @@instructions = []

    def self.build(size)
        output = []
        Fragment.all.sample(size).each do |c|
            lang = c.language
            adjective = lang.language_adjectives.sample.id
            output.push(c.build(adjective))
        end
        return output
    end

    def build(language_adjective_id)
        puts "LANGUAGE ID ISSSSS"
        language_adjective = LanguageAdjective.find(language_adjective_id)
        english_adjective = language_adjective.adjective

        hash = {}

        english = ""
        roman = ""
        original =""

        original_instructions = self.instructions
        roman_instructions = self.roman_instructions
        
        self.english.scan(/\(([^\)]+)\)/).try(:flatten).try(:each) do |match|
            next if english_adjective[match] == nil
            english = self.english.gsub("(#{match})", english_adjective[match])
        end

        self.roman.scan(/\(([^\)]+)\)/).try(:flatten).try(:each) do |match|
            next if language_adjective.folder[match] == nil
            roman = self.roman.gsub("(#{match})", polished(language_adjective.folder[match], roman_instructions))
        end

        self.original.scan(/\(([^\)]+)\)/).try(:flatten).try(:each) do |match|
            next if language_adjective.folder[match] == nil
            original = self.original.gsub("(#{match})", polished(language_adjective.folder[match], original_instructions))
        end

        ln = self.language.language_nouns.sample

        english = english.gsub("(noun)", ln.noun.base)
        roman = roman.gsub("(noun)", ln.folder["roman"])
        original = original.gsub("(noun)", ln.folder["base"])

        hash = {
            "english" => english,
            "original" => original,
            "roman" => roman,
            "tags" => self.tags,
            "meta" => {
                "language" => self.language,
                "fragment_id" => self.id,
                "language_adjective_id" => language_adjective.id,
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
        Fragment.all.each do |c|
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
    def polished(word, sets)
        return word if instructions.nil?
        sets.each do |set|
            next if !passing?((set["conditions"] || []), word, "")
            set["instructions"].try(:each) do |obj|
                puts "BEFORE: #{word}"
                puts "#{obj["style"]} #{obj["instruction"]}"
                case obj["style"]
                when "delete_prefix"
                    if (obj["instruction"].to_i.to_s == obj["instruction"])
                        i = obj["instruction"].to_i
                        word = word[i..-1]
                    else
                        word = word.delete_prefix(obj["instruction"])
                    end
                when "delete_suffix"
                    if (obj["instruction"].to_i.to_s == obj["instruction"])
                        i = obj["instruction"].to_i
                        position = word.length - i
                        word = word[0..(position - 1)]
                    else
                        word = word.delete_suffix(obj["instruction"])
                    end

                when "add_prefix"
                    word = obj["instruction"] + word

                when "add_suffix"
                    word = word + obj["instruction"]

                when "replace_prefix"
                    this = obj["instruction"].split(", ")[0]
                    that = obj["instruction"].split(", ")[1]

                    if that == "''"
                        that = ""
                    end
                    word = that + word.delete_prefix(this)

                when "replace_suffix"
                    this = obj["instruction"].split(", ")[0]
                    that = obj["instruction"].split(", ")[1]

                    if that == "''"
                        that = ""
                    end
                    word = word.delete_suffix(this) + that
                when "flip_prefix"
                    range = obj["instruction"].to_i
                    word = word[0..range].reverse + word[(range+1)..-1]
                when "flip_suffix"
                    range = obj["instruction"].to_i
                    position = word.length - range
                    word = word[0..(position-1)] + word[position..-1].reverse
                else
                    break
                end
                
                puts "AFTER: #{word}"
                puts "########"
            end
        end

        return word
    end

    def passing? conditions, string, store
        puts 'CONDITIONS'
        bool = true
        conditions.each do |condition|
            return if ConditionChecker.test(condition, string, store) == false
        end
        # return bool
        return true
    end
end
