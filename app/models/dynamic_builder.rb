class DynamicBuilder < ApplicationRecord

    class << self
        def build(options)
            @@outputs = {}
            @@sources = {}


            @@language = options[:language]
            @@items = makeItems(options[:items_manifest])
            @@dynamic = options[:dynamic]
            @@output_variables = @@dynamic["output_variables"].each_with_object({}) { |element, hash| hash[element] = "" }

            steps = @@dynamic.steps 
            # steps = options[:steps]

            puts "steps: ++++"
            puts steps

            steps.each do |step|
                traverse(step)
            end


            {
                items: @@items,
                steps: options[:steps],
                outputs: @@output_variables,
                sources: @@sources
            }
        end

        def makeItems(items_manifest)
            items = {}
            items_manifest.each do |key, input|
                next if (!key.present? || key === "undefined") && !input.present?
                puts "KEY: #{key}, VALUE: #{input}"
                if input.key?(:id) || input.key?("id")
                    puts "MATERIAL ID: #{input["id"]}"
                    if input["id"] === nil
                        puts "IS NULL"
                        next if key === "undefined" || key.empty?
                        items[key] = @@language.sample_material_by_title(key)
                    else
                        items[key] = FactoryMaterial.find(input["id"]) || {"error" => "Material not found"}  # Handle case where material is not found                        
                        puts "ITEM: #{items[key]}"
                    end
                    @@sources[key] = items[key]
                elsif input["val"].present?
                    items[key] = input["val"]
                end
            end
            puts ")))))"
            puts items_manifest
            puts items
            puts ")))))"
            return items
        end

        def traverse(starter, depth = 0)

            stack = []
            stack.push(starter)

            while stack.length > 0
                step = stack.pop
                
                passing = []
                
                if step[:conditional] === true
                    

    
                    step[:if_statements].each do |s|
                        # puts "#{s["left"]} #{s["center"]} #{s["right"]}"
                        material = @@items[s["left"].split("[]")[0]]
    
                        passing.push(testCondition(s))
                        # puts "~~~~"
                    end
                else
                    if step[:passing] === true || (step[:dynamic_rule_id] == nil)
                        # puts "STEP**: #{step}"
                        puts "Doing Step: #{rule_type(step[:conditional])} #{step[:title]}"

                        then_statements = step.dig(:then_statements) || step.dig("then_statements")

                        then_statements.each do |s|
                            # puts "#{s}"
                            # puts "#{s["left"]} #{s["center"]} #{s["right"]}"
                            
                            # passing.push(testCondition(s, material))
                            # puts "++++"
                            # puts "Add suffix"
                            receiver = s["receiver"]
                            # puts "reciever #{s["receiver"]}"
                            
                            if !receiver.present?
                                final = morpher(s, s["value"])
                            else
                                if receiver.start_with? "$"
                                    ov_key = receiver.split("$")[1]
                                    value = @@output_variables[ov_key]
                                    # puts "#{ov_key} -> #{value}"
                                    final = morpher(s, value)
                                else
                                    if s['left'].blank? && s['rule'] === "init"
                                        final = morpher(s, s["value"])
                                    else
                                        material = receiver.split("[")[0]
                                        key = receiver.split("[")[1].split("]")[0]
                                        # puts "material #{material}"
                                        # puts "items #{@@items}"
                                        value = @@items[material]['folder'][key]
                                        final = morpher(s, value)
                                    end
                                end
                            end

                            @@output_variables[s["output_variable"]] = final
                        end
                    end
                end
                # Push children onto the stack with increased depth
                children = step.dig(:children) || step.dig("children")
                children.reverse_each do |child|
                    if passing.all?
                        child[:passing] = true
                        stack.push(child)
                    end 
                end
            end
        end

        def testCondition(step)
            # puts "_+_+"
            # puts "Test Condition #{step}"
            material = step["left"].split("[")[0]
            key = step["left"].split("[")[1].split("]")[0]
            puts ")))))))))"
            puts  @@items
            puts ")))))))))"
            value = @@items[material]['folder'][key]
            right = step["right"]
            
            case step["center"]
            when "==", "==="
                # puts "checking: #{value} === #{right}"
                # puts "under hood: #{value === right}"
                return value === right ? true : false
            when "includes?"
                # puts "checking: #{value} includes? #{right}"
                return (value.include? right) ? true : false
            when "start_with?"
                # puts "checking: #{value} starts_with #{right}"
                return (value.start_with? right) ? true : false
            when "end_with?"
                # puts "checking: #{value} ends with #{right}"
                return (value.end_with? right) ? true : false
            when "!end_with?"
                # puts "checking: #{value} ends with #{right}"
                return (!value.end_with? right) ? true : false
            when "present?"
                # puts "checking: presence of #{value}"
                return value.present? ? true : false
            else
                return false
            end
        end

        def morpher(obj, word)

                template = obj["value"].gsub(/\${([^\}]+)}|#\{([^\}]+)}/) do |match|

                    matched = $1 || $2
                    # puts "MATCHING: #{matched}"
                    if matched.include? "["


                        material = matched.split("[")[0]
                        key = matched.split("[")[1].split("]")[0]
                        
                        if material.include? "ENGLISH"
                            material = material.split(".ENGLISH")[0]
                            # puts "ENGLISH: "
                            # puts @@items[material].materialable[key]
                            replacement = @@items[material].materialable[key]
                        else
                            # puts "THIS___ #{@@items[material]['folder']}"
                            replacement = @@items[material]['folder'][key]
                        end
                    else
                        replacement = @@output_variables[matched]
                    end
                    # puts "Matched: #{match}, Replaced with: #{replacement}"
                    replacement  # Make sure to include this line to return the replacement value
                end

                obj["value"] = template

            case obj["rule"]
            when "init"
                word = obj["value"] 

            when "delete_prefix"
                if (obj["value"].to_i.to_s == obj["value"])
                    i = obj["value"].to_i
                    word = word[i..-1]
                else
                    word = word.delete_prefix(obj["value"])
                end
            when "delete_suffix"
                if (obj["value"].to_i.to_s == obj["value"])
                    i = obj["value"].to_i
                    position = word.length - i
                    word = word[0..(position - 1)]
                else
                    word = word.delete_suffix(obj["value"])
                end

            when "add_prefix"
                word = obj["value"] + word

            when "add_suffix"
                if obj["value"].include? "~"
                    dynaAttr = obj["value"][/~(.*?)~/, 1]
                    # puts "$$$$ dyno #{dynaAttr}"

                    if dynaAttr.start_with? "eng:"
						engObj = @@factory_material.materialable
                        string = engObj[dynaAttr.split("eng:")[1].to_sym]
                    else
                        string = @@factory_material.folder[dynaAttr]
                    end

                    word = word + string
                else

                    word = word + obj["value"]
                end

            when "replace_prefix"
                this = obj["value"].split(", ")[0]
                that = obj["value"].split(", ")[1]

                if that == "''"
                    that = ""
                end
                word = that + word.delete_prefix(this)

            when "replace_suffix"
                this = obj["value"].split(", ")[0]
                that = obj["value"].split(", ")[1]

                if that == "''"
                    that = ""
                end
                word = word.delete_suffix(this) + that
            when "flip_prefix"
                range = obj["value"].to_i
                word = word[0..range].reverse + word[(range+1)..-1]
            when "flip_suffix"
                range = obj["value"].to_i
                position = word.length - range
                word = word[0..(position-1)] + word[position..-1].reverse
            when "add_dynamic"
                dynamic = FactoryDynamic.find(obj["value"].split("|")[0])
                cat = obj["value"].split("|")[1]
                # puts "THE DYNA MATEIRAL WE NEED: #{@@factory_material.id} with the dynamic: #{dynamic.title}"
                word = word + dynamic.build(@@factory_material.id)[cat.to_sym]
            else

            end
            return word
        end

        def rule_type(conditional)
            return conditional ? "If" : "Then"
        end


        def convert_keys_to_strings(hash)
            case value
            when Hash
                value.each_with_object({}) do |(key, inner_value), result|
                new_key = key.is_a?(Symbol) ? key.to_s : key
                new_inner_value = convert_keys_to_strings(inner_value)
                result[new_key] = new_inner_value
                end
            when Array
                value.map { |item| convert_keys_to_strings(item) }
            else
                value
            end
        end



    end
end
