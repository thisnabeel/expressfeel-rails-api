class VerbSerializer < ActiveModel::Serializer
  attributes :id, :infinitive, :category, :past, :present, :created_at, :updated_at, :identifier
end