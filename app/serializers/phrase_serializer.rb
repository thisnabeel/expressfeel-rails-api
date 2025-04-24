class PhraseSerializer < ActiveModel::Serializer
  attributes :id, :title, :body, :recording, :tags, :position, :language_id, :lesson_id, :created_at, :updated_at, :translit, :formula, :ready, :phrase_factories
  has_one :lesson
  attribute :language
  attribute :phrase_inputs
  attribute :inputtable_items
  attribute :phrase_dynamics, unless: -> { @instance_options[:just_phrase] == true }


  def phrase_inputs
    object.phrase_inputs.map {|pd| PhraseInputSerializer.new(pd)}
  end

  def inputtable_items
    object.language.factories.map {|f| {category: "Factory", title: f.name, item: f}} + object.language.factory_dynamics.map {|fd| {category: "FactoryDynamic", title: fd.title, item: fd}} + object.language.phrases.map {|p| {category: "Phrase", title: p.title == "New Phrase" ? p.lesson.objective : p.title, item: p}}
  end

  def phrase_dynamics
    object.phrase_dynamics.map {|pd| PhraseDynamicSerializer.new(pd)}
  end

  def phrase_factories
    object.phrase_factories.map {|pd| PhraseFactorySerializer.new(pd)}
  end

  def language
    object.language
  end
end