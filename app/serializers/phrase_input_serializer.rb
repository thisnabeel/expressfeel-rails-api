class PhraseInputSerializer < ActiveModel::Serializer
  attributes :id, :phrase_inputable_type, :phrase_inputable_id, :code, :position, :phrase_id, :phrase_inputable, :outputs, :inputs, :english_outputs, :phrase_input_permits


  def phrase_input_permits
    object.phrase_input_permits.map {|p| PhraseInputPermitSerializer.new(p)}
  end

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

  def english_outputs(input = object, depth = 0, max_depth = 5)
    return {} if depth > max_depth

    case input.phrase_inputable_type
    when "Factory"
      {
        input.code => input.phrase_inputable.materialable_type.constantize
                            .column_names - %w[id created_at updated_at]
      }
    when "Phrase"
      input.phrase_inputable.phrase_inputs.each_with_object({}) do |pi, result|
        result.merge!(english_outputs(pi, depth + 1, max_depth))
      end
    else
      {}
    end
  end

  def inputs
    if object.phrase_inputable_type === "FactoryDynamic"
      return object.phrase_inputable.factory_dynamic_inputs.map {|fdi| fdi.attributes.merge(payload: PhraseInputPayload.find_by(phrase_input_id: object.id, factory_dynamic_input_id: fdi.id))}
    elsif object.phrase_inputable_type === "Phrase"
      return object.phrase_inputable.phrase_inputs.map {|pi| pi.attributes.merge(payload: PhraseInputPayload.find_by(phrase_input_id: object.id, factory_dynamic_input_id: pi.id))}
    else
      return []
    end
  end
end
