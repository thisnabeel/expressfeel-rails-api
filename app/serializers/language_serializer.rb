class LanguageSerializer < ActiveModel::Serializer
  attributes :id, :title, :created_at, :updated_at, :direction
  attribute :factories, unless: -> { @instance_options[:language_only] == true }
  attribute :dynamics, unless: -> { @instance_options[:language_only] == true } 

  def factories
    object.factories.map {|factory| FactorySerializer.new(factory)}
  end

  def dynamics
    object.factory_dynamics.map {|dynamic| FactoryDynamicSerializer.new(dynamic)}
  end

# json.factories language.factories
# json.factories language.factories do |factory|
#   json.id factory.id
#   json.name factory.name
#   json.materials_title factory.materials_title
#   json.rules factory.factory_rules.pluck(:title)
# end


end
