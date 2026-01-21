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
        return "" unless @exports[code].present?
        if  @category.to_s === "english"
          if @block["english_material_code"] && @block["english_material_attribute"]
            return "" unless @exports[code][:built] && @exports[code][:built][:exports]
            return @exports[code][:built][:exports][@block["english_material_code"]][:english_material][@block["english_material_attribute"]] || ""
          elsif !@block["english_material_code"] && @block["english_material_attribute"]
            return @exports[code][:english_material]&.[](@block["english_material_attribute"]) || ""
          else
            built_output = @exports[code][:built]&.[](@category) || ""
            return inject_custom_texts(built_output, code)
          end
        else
          built_output = @exports[code][:built]&.[](@category) || ""
          return inject_custom_texts(built_output, code)
        end
      end
      category_output_key = @block["output_key"] + "_#{@category}"


      details = @exports[code]
      return "" unless details.present?
      if details[:built]
        value = details[:built][category_output_key]
        value = inject_custom_texts(value, code, output_key) if value.present?
        value
      else
        if @category.to_s === "english"
          value = details[:english_material]&.[](output_key)
        else
          value = details[:language_material]&.factory_material_details&.find_by(slug: output_key)&.value
        end
        value || ""
      end

    elsif @block["body"].present?
      @block["body"]
    else
      ""
    end
  end

  private

  def inject_custom_texts(output, code, output_key = nil)
    # Safely read inserted_texts for this category (may be nil/empty)
    inserted_texts =
      if @block["inserted_texts"].is_a?(Hash)
        @block["inserted_texts"][@category.to_s]
      else
        nil
      end
    inserted_texts = inserted_texts.is_a?(Hash) ? inserted_texts : {}
  
    # Get the referenced phrase to access its formula blocks
    phrase_input = @phrase.phrase_inputs.find { |pi| pi.code == code }
    return output unless phrase_input && phrase_input.phrase_inputable_type == "Phrase"
    
    referenced_phrase = phrase_input.phrase_inputable
    return output unless referenced_phrase.formula && referenced_phrase.formula[@category.to_s]
    
    # Build individual blocks from referenced phrase
    blocks = referenced_phrase.formula[@category.to_s]
    catalog = @catalog || {}
    material_selections = {}
    exports = @exports[code]&.[](:built)&.[](:exports) || {}
    factories = @factories || []
    
    built_blocks = blocks.map do |block|
      PhraseBlockResolver.resolve(
        referenced_phrase, 
        block, 
        catalog, 
        @language_id, 
        material_selections, 
        @category, 
        exports, 
        factories
      ).to_s
    end
    
    # Apply block order swaps first (swap adjacent blocks) – this works even if no inserted_texts
    block_order_swaps = @block["block_order_swaps"]&.[](@category.to_s)
    if block_order_swaps.is_a?(Hash) && block_order_swaps.present?
      # Process swaps from the end to avoid index issues
      (built_blocks.length - 1).downto(0) do |i|
        if block_order_swaps[i.to_s] == true || block_order_swaps[i] == true
          # Swap blocks at position i and i+1
          if i + 1 < built_blocks.length
            built_blocks[i], built_blocks[i + 1] = built_blocks[i + 1], built_blocks[i]
          end
        end
      end
    end

    # Optional extra paddings per referenced block (from UI "btn spacer" on block-key-item)
    block_paddings = @block["block_paddings"]&.[](@category.to_s)
    block_paddings = nil unless block_paddings.is_a?(Hash)
  
    # Insert custom texts at specified positions (if any) and apply extra paddings
    result = []
    built_blocks.each_with_index do |block_output, index|
      # Apply extra padding around this block if specified
      if block_paddings
        pad_cfg = block_paddings[index.to_s] || block_paddings[index]
        if pad_cfg.is_a?(Hash)
          pad_left  = pad_cfg["left"]  || pad_cfg[:left]
          pad_right = pad_cfg["right"] || pad_cfg[:right]
          block_output = "#{pad_left ? ' ' : ''}#{block_output}#{pad_right ? ' ' : ''}"
        end
      end

      result << block_output
      # Insert custom text after this block if specified
      insert_data = inserted_texts[index.to_s]
      if insert_data.present?
        insert_value = insert_data.is_a?(Hash) ? insert_data["value"] || insert_data[:value] : insert_data
        if insert_value.present?
          padding_left = (insert_data.is_a?(Hash) && (insert_data["padding_left"] || insert_data[:padding_left])) ? " " : ""
          padding_right = (insert_data.is_a?(Hash) && (insert_data["padding_right"] || insert_data[:padding_right])) ? " " : ""
          result << padding_left + insert_value.to_s + padding_right
        end
      end
    end
    
    result.join
  end

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
