class NounSerializer < ActiveModel::Serializer
  attributes :id, :base, :category, :tags, :created_at, :updated_at, :proper, :quantity, :identifier
end