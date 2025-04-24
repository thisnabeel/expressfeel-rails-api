class FactoryDynamicInput < ApplicationRecord
  belongs_to :factory, optional: true
  belongs_to :factory_dynamic
  has_many :factory_dynamic_outputs
end
