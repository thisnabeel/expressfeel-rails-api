class PronounSerializer < ActiveModel::Serializer
  attributes :id, :word, :category, :tags, :created_at, :updated_at, :possession, :object_word, :is_word, :do_word, :has_word, :countable, :identifier
end