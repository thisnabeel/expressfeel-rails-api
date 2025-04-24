class ConjugationRule < ActiveRecord::Base
    belongs_to :language
    belongs_to :trait
    serialize :rules, coder: JSON
end
