class Verb < ActiveRecord::Base
    has_many :language_verbs
    has_many :materials, as: :materialable
end
