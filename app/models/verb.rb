class Verb < ActiveRecord::Base
    has_many :language_verbs
    has_many :materials, as: :materialable

    def identifier
        self.infinitive
    end
end
