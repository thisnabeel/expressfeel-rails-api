
class Conjugator::Levantine < ActiveRecord::Base

    require 'arabic-letter-connector'

    @@root = []
    @@hash = {}
    
    @@past_english = ""
    @@present_english = ""

    class << self
    
        def build(options = {})
            # return "HI"
            @@root = options[:root].split(" ")
            @@past_english = options[:past_english]
            @@present_english = options[:present_english]

            i_did
            we_did
            do_it
            you_did

            return @@hash
        end

        def i_did
            root = joined + "ِت"
            
            @@hash["i_did"] = {
                original: sanitize(root),
                translation: "I " + @@past_english + "."
            }
        end

        def we_did
            root = joined + "نَا"
            
            @@hash["we_did"] = {
                original: sanitize(root),
                translation: "We " + @@past_english + "."
            }
        end

        def they_did
            root = joined + "و"
            
            @@hash["they_did"] = {
                original: sanitize(root),
                translation: "They " + @@past_english + "."
            }
        end

        def you_did

            @@hash["you_masculine_did_it"] = {
                original: sanitize(joined + "ِت"),
                translation: "You " + @@past_english + "."
            }

            @@hash["you_feminine_did_it"] = {
                original: sanitize(joined + "ْتِي"),
                translation: "You " + @@past_english + "."
            }

            @@hash["you_all_did_it"] = {
                original: sanitize(joined + "ُْو"),
                translation: "You all " + @@past_english + "."
            }

            
        end

        def do_it
            root = "أُ" + joined

            
            @@hash["do_it_masculine"] = {
                original: sanitize(root),
                translation: @@present_english + "!"
            }

            @@hash["do_it_feminine"] = {
                original: sanitize(root + "ي"),
                translation: @@present_english + "!"
            }

            @@hash["do_it_plural"] = {
                original: sanitize(root + "و") ,
                translation: @@present_english + "!"
            }

        end

        def joined
            @@root.join("")
        end

        def sanitize(root)
            return root
        end
    end
end