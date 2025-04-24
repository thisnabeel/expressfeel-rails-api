class LanguageAdjective < ActiveRecord::Base
    belongs_to :adjective
    belongs_to :language

    serialize :folder, coder: JSON
end
