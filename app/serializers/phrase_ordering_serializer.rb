class PhraseOrderingSerializer < ActiveModel::Serializer
  attributes :id, :line, :description, :position, :category
end
