class Noun < ActiveRecord::Base
    has_many :language_nouns
    has_many :materials, as: :materialable

    def identifier
        self.base
    end
end
