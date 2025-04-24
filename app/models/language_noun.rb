class LanguageNoun < ActiveRecord::Base
    belongs_to :noun
    belongs_to :language

    serialize :folder, coder: JSON
end
