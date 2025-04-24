class PhraseInputSerializer < ActiveModel::Serializer
  attributes :id, :phrase_inputable_type, :phrase_inputable_id, :code, :position, :phrase_id, :phrase_inputable, :outputs, :inputs, :english_outputs

  def phrase_inputable
    object.phrase_inputable
  end

  def outputs
    if object.phrase_inputable_type === "FactoryDynamic"
      return object.phrase_inputable.factory_dynamic_outputs
    elsif object.phrase_inputable_type === "Factory"
      return object.phrase_inputable.factory_rules
    end
  end

  def english_outputs
    if object.phrase_inputable_type === "Factory"
      object.phrase_inputable.materialable_type.constantize.column_names - ['id', 'created_at', 'updated_at']
    end
  end

  def inputs
    if object.phrase_inputable_type === "FactoryDynamic"
      return object.phrase_inputable.factory_dynamic_inputs.map {|fdi| fdi.attributes.merge(payload: PhraseInputPayload.find_by(phrase_input_id: object.id, factory_dynamic_input_id: fdi.id))}
    else
      return []
    end
  end
end
