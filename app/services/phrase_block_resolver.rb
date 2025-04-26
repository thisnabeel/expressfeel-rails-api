class PhraseBlockResolver
  def self.resolve(phrase, block, catalog, language_id, material_selections, category, exports, factories)
    new(phrase, block, catalog, language_id, material_selections, category, exports, factories).resolve
  end

  def initialize(phrase, block, catalog, language_id, material_selections, category, exports, factories)
    @phrase = phrase
    @factories = factories
    @block = block
    @catalog = catalog
    @language_id = language_id
    @material_selections = material_selections
    @category = category
    @exports = exports
    @primary_pass = category.to_sym == :original
  end

  def resolve
    export_packager(@block)

    if @block["output_variable"].present?
      resolve_output_variable
    elsif @block["material"].present? && @block["attribute"].present?
      resolve_fallback_material
    elsif @block["phrase_id"].present?
      return "" if @phrase.id === @block["phrase_id"]

      nested_phrase = Phrase.find(@block["phrase_id"])
      nested_output = nested_phrase.build

      nested_exports = nested_output[:exports] || {}
      if @primary_pass
        nested_exports.each do |export_key, export_value|
          namespaced_key = "#{export_key}_#{nested_phrase.id}"
          @exports[namespaced_key] ||= {}
          @exports[namespaced_key].merge!(export_value)
        end
      end

      nested_output[@category] || ""
    elsif @block["phrase_factory_id"].present?
      pf = @exports.values.find { |export| export[:id] == @block["phrase_factory_id"] }


      if @category.to_s === "english"
        pf[:english][@block["material_key"].to_sym]
      else
        pf[:material].folder[@block["material_key"]]
      end
    elsif @block["phrase_input_code"].present?
      code = @block["phrase_input_code"]
      output_key = @block["output_key"]

      if !@block["output_key"].present?
        if  @category.to_s === "english"
          if @block["english_material_code"] && @block["english_material_attribute"]
            
            return @exports[code][:built][:exports][@block["english_material_code"]][:english_material][@block["english_material_attribute"]]
          elsif !@block["english_material_code"] && @block["english_material_attribute"]
            return @exports[code][:english_material][@block["english_material_attribute"]]
          else
            return @exports[code][:built][@category]
          end
        else
          return @exports[code][:built][@category]
        end
      end
      category_output_key = @block["output_key"] + "_#{@category}"


      details = @exports[code]
      if details[:built]
        value = details[:built][category_output_key]
        value
      else
        if @category.to_s === "english"
          value = details[:english_material][output_key]
        else
          value = details[:language_material].factory_material_details.find_by(slug: output_key)&.value
        end
        value
      end

    elsif @block["body"].present?
      @block["body"]
    else
      ""
    end
  end

  private

  def export_packager(block)
    return unless @primary_pass
    return unless block["export_code"] && block["material"] && block["attribute"]

    export_key = block["export_code"]
    material_key = "#{block["material"]}_#{@language_id}"

    material = @material_selections[material_key]
    unless material
      factory = Factory.find_by(materials_title: block["material"], language_id: @language_id)
      return unless factory
      material = factory.factory_materials.sample
      return unless material
      @material_selections[material_key] = material
    end

    @exports[export_key] ||= {}
    materialable = material.materialable
    @exports[export_key][:english] = materialable if materialable
  end


  def resolve_output_variable
    selection = @catalog[@block["phrase_dynamic_id"]]
    return "" unless selection

    if @block["output_variable"].start_with? "$"
      source_key = @block["output_variable"].delete_prefix("$")
      source = selection[:sources][source_key]

      if @block["factory_rule"].start_with? "$"
        attr = @block["factory_rule"].delete_prefix("$").to_sym
        source.materialable[attr]
      else
        source[:folder][@block["factory_rule"]]
      end
    else
      selection[:outputs][@block["output_variable"]]
    end
  end

  def resolve_fallback_material
    material_key = "#{@block["material"]}_#{@language_id}"
    material = @material_selections[material_key]

    if material.nil?
      if @primary_pass
        factory = Factory.find_by(materials_title: @block["material"], language_id: @language_id)
        return "[Material Not Found]" unless factory
        material = factory.factory_materials.sample
        return "[No Material]" unless material
        @material_selections[material_key] = material
      else
        return "[Material Skipped]"
      end
    end

    if @block["attribute"].start_with?("eng:")
      attr = @block["attribute"].split(":")[1]
      material.materialable&.[](attr.to_sym) || "nil"
    else
      material.folder[@block["attribute"]]
    end
  end

end
