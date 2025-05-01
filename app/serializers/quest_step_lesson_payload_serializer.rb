class QuestStepLessonPayloadSerializer < ActiveModel::Serializer
  attributes :id, :materialable_type, :materialable_id, :identifier

  def identifier
    object.materialable.identifier
  end
end
