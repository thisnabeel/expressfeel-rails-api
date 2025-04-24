class PhraseFactorySerializer < ActiveModel::Serializer
  attributes :id, :position, :code, :factory

  def factory
    FactorySerializer.new(object.factory)
  end
end
