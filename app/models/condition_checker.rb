class ConditionChecker < ActiveRecord::Base

    class << self

        @@store = {}

        def options
            return {
                "==" => "equals",
                ".include?" => "includes",
            }
        end

        def test(specimen, statement, params = nil)
            puts "The Statement is:"
            puts statement


            if (statement["left"].include? "[") && params.present?
                key = statement["left"].split("[")[0] + "s"

                attribute = statement["left"][/\[(.*?)\]/, 1]
                sample = params[key]

                return false if !sample.present?

                puts "Example: #{sample.attributes} is \n ***#{sample.folder[attribute]}***"
                specimen = params[key]
                left = sanitize(sample.folder[attribute])
            else
                left = sanitize(specimen[statement["left"]])
            end

            right = sanitize(statement["right"])

            case statement["center"]
            when "==", "==="
                puts "checking ===: #{left} === #{right}"
                puts "under hood: #{left === right}"
                return left === right ? true : false
            when "includes?"
                puts "checking: #{left} includes? #{right}"
                return (left.include? right) ? true : false
            when "start_with?"
                puts "checking: #{left} starts_with #{right}"
                return (left.start_with? right) ? true : false
            when "end_with?"
                puts "checking: #{left} ends with #{right}"
                return (left.end_with? right) ? true : false
            else
                return false
            end
        end

        def sanitize(string)
            # return @@store[string] if @@store[string].present?
            return string
        end
    end
end