class FactoryDynamicService
  def initialize(config:, inputs:, funnels:, outputs:)
    @config = config
    @inputs = inputs
    @funnels = funnels
    @outputs = {}
    initalize_outputs(outputs)
  end

  def run
    walk_tree(@config["start"], @funnels)
  end

  private

  def walk_tree(node, context)
    if node.is_a?(Array)
      node.each { |step| apply_morph(step, context) }
      return @outputs
    end
    # return interpolate(node["value"], context) if node["value"]
    return "" if node["error"]

    if node["if"]
      condition = node["if"]["condition"] || "true"
      # Handle both array and string with && operators
      if condition.is_a?(String) && condition.include?("&&")
        conditions = condition.split("&&").map(&:strip)
      else
      conditions = Array(condition)
      end
      condition_passing = !conditions.map {|c| evaluate_condition(c, context)}.include?(false)
      if condition_passing
        return walk_tree(node["if"]["then"], context)
      elsif node["if"]["else"]
        return walk_tree(node["if"]["else"], context)
      end
    end

    if node["sequence"]
      node["sequence"].each do |morph_step|
        if morph_step["if"]
          condition = morph_step["if"]["condition"] || "true"
          # Handle both array and string with && operators
          if condition.is_a?(String) && condition.include?("&&")
            conditions = condition.split("&&").map(&:strip)
          else
          conditions = Array(condition)
          end
          condition_passing = !conditions.map {|c| evaluate_condition(c, context)}.include?(false)
          if condition_passing
            run_morph_chain(morph_step["if"]["then"], context)
          elsif morph_step["if"]["else"]
            run_morph_chain(morph_step["if"]["else"], context)
          end
        elsif morph_step["then"]
          run_morph_chain(morph_step["then"], context)
        elsif morph_step["default"]
          run_morph_chain(morph_step["default"], context)
        elsif morph_step["sequence"]
          walk_tree(morph_step, context)
        else
          apply_morph(morph_step, context)
        end
      end

      puts "[DEBUG] Final @outputs: #{@outputs.inspect}"
    end
    return @outputs
  end

  def run_morph_chain(steps, context)
    if steps.is_a?(Array)
      steps.each do |s|
        puts "[DEBUG] Running morph step: #{s.inspect}"
        key = s.keys.first
        puts "-- first key is #{key}"
        if key == "sequence"
          walk_tree(s, context)
        elsif key == "if"
          walk_tree(s, context)
        else
          apply_morph(s, context)
        end
      end
    else
      apply_morph(steps, context)
    end
    @outputs
  end

  def apply_morph(node, context)
    return if node["error"]

    base_id = node["id"]

    # STEP 1: Handle copy_from first
    if node["copy_from"]
      funnel_find(base_id, node["copy_from"])
    else
      # binding.pry
      # STEP 2: Always ensure _original and _roman values exist
      %w[original roman].each do |category|
        full_key = "#{base_id}_#{category}"
        @outputs[full_key] ||= ""
      end
      
      # STEP 3: Handle category-specific morphs like add_suffix#original
      node.each do |key, val|
        if key.include?("#")
          morph_type, category = key.split("#")
          next unless %w[original roman].include?(category)
  
          full_key = "#{base_id}_#{category}"
          @outputs[full_key] ||= ""
          current = @outputs[full_key]
          val = interpolate(val, context)
  
          case morph_type
          when "add_prefix"
            current = "#{val}#{current}"
          when "add_suffix"
            current = "#{current}#{val}"
          when "delete_prefix"
            current = current.sub(/^#{Regexp.escape(val)}/, '')
          when "delete_suffix"
            current = current.sub(/#{Regexp.escape(val)}$/, '')
          end
  
          @outputs[full_key] = current
          puts "[DEBUG] #{morph_type}##{category} on #{full_key}: #{@outputs[full_key]}"
        end
      end
    end
  end


  def funnel_find(id, copy_from)
    return unless copy_from

    key, slug = copy_from.split("#")
    return unless key && slug
    return unless @funnels[key]

    material_details = @funnels[key]["factory_material"]["factory_material_details".to_sym]
    return unless material_details.is_a?(Array)

    %w[_original _roman].each do |category|
      categorized_slug = slug + category
      item = material_details.find { |detail| detail[:slug] == categorized_slug }

      value = item ? item[:value] : ""
      @outputs[id + category] = value
      puts "[DEBUG] Set @outputs[#{id + category}] = #{value.inspect}"
    end
  end

  def interpolate(str, context)
    return str unless str.is_a?(String)
    str.gsub(/\{\{(\w+)\}\}/) { context[$1].to_s }
  end

  def evaluate_condition(condition_str, context)
    return true if condition_str.strip == "true"
    return false if condition_str.strip == "false"

    match = condition_str.strip.match(/([\w\.]+)\s*(==|!=)\s*['"]([^'"]+)['"]/)
    return false unless match

    lhs, op, rhs = match.captures
    obj,key = lhs.split(".")
    return false unless context[obj] && context[obj]["factory_material"]
    
    # First try to find in factory_material_details
    material_details = context[obj]["factory_material"]["factory_material_details".to_sym]
    card = material_details.is_a?(Array) ? material_details.find { |detail| detail[:slug] == key } : nil

    # If not found in details, try to access materialable properties
    if card.nil? && context[obj]["factory_material"]["materialable_id"].present?
      materialable_type = context[obj]["factory_material"]["materialable_type"]
      materialable_id = context[obj]["factory_material"]["materialable_id"]
      
      if materialable_type && materialable_id
        begin
          materialable_class = materialable_type.constantize
          materialable = materialable_class.find_by(id: materialable_id)
          if materialable
            # Try direct attribute access first
            if materialable.respond_to?(key.to_sym)
              value = materialable.send(key.to_sym)
              case op
              when '=='
                return value.to_s == rhs
              when '!='
                return value.to_s != rhs
              end
            # Try accessing as hash key (for serialized attributes)
            elsif materialable.respond_to?(:[]) && materialable[key.to_s]
              value = materialable[key.to_s]
              case op
              when '=='
                return value.to_s == rhs
              when '!='
                return value.to_s != rhs
              end
            end
          end
        rescue => e
          # If materialable lookup fails, fall through to check details
        end
      end
    end

    # Fallback to factory_material_details
    if key.include?("roman") && !card.present?
      return false
    end
    
    return false unless card
    value = card[:value] 

    case op
    when '=='
      value == rhs
    when '!='
      value != rhs
    else
      false
    end
  end

  def initalize_outputs(items)
    items.each do |item|
      # @outputs[item.slug] = @outputs[item.slug] || ""
      
      material_key = item.factory_dynamic_input.slug
      begin
        material_details = @funnels[material_key]["factory_material"]["factory_material_details".to_sym]
      rescue => e
        # binding.pry
        material_details = {}
      end
      
      # return unless material_details.is_a?(Array)
      %w[_original _roman].each do |category|

        if !item[:initial_input_key].present?
          # binding.pry
        end

        categorized_key = item[:initial_input_key] + category
        categorized_key = categorized_key.gsub("_original_original", '_original')
        
        md = material_details.find { |detail| detail[:slug] == categorized_key }

        value = md ? md[:value] : ""
        @outputs[item[:slug] + category] = value
        puts "[DEBUG] Set @outputs[#{item[:slug] + category}] = #{value.inspect}"
      end
    end
  end
end
