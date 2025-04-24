class DynamicRule < ApplicationRecord
    belongs_to :factory_dynamic
    belongs_to :dynamic_rule, optional: true
end
