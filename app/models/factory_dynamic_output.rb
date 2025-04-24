class FactoryDynamicOutput < ApplicationRecord
  belongs_to :factory_dynamic_input
  has_one :factory_dynamic, through: :factory_dynamic_input
end
