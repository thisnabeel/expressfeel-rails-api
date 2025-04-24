class LanguageVerb < ActiveRecord::Base
    belongs_to :verb
    belongs_to :language

    serialize :folder, coder: JSON

    def blocks_quiz(conjugation = nil)
        
        conjugations = self.language.conjugations.sample(3)
        options = []

        conjugations.each do |conj|
            options.push(conj.build(self.id))
        end
    
        if conjugation.present?
            built = conjugation.build(self.id)
            options.push(built)
            main = built
        else
            main = options[0]
        end

        options = options.shuffle

        original = main["original"]
        roman = main["roman"]
        english = main["english"]
        tags = main["tags"]

        original_blocks = []
        roman_blocks = []
        options.each do |option|
            option["original"].split(" ").each {|o| original_blocks.push(o)}
            option["roman"].split(" ").each {|o| roman_blocks.push(o.downcase)}
        end
        
        return {
            original: original,
            original_blocks: original_blocks.uniq.shuffle,
            direction: self.language.direction,
            english: english,
            roman: roman.downcase,
            roman_blocks: roman_blocks.uniq.shuffle,
            tags: tags,
            meta: {
                "language" => self.language,
                "language_verb_id" => self.id,
            }
        }
    end
    
end
