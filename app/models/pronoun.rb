class Pronoun < ActiveRecord::Base

    def identifier
        self.word
    end
end
