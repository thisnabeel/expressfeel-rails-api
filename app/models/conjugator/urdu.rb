
class Conjugator::Urdu < ActiveRecord::Base

    @@root = []
    @@roman = ""
    @@hash = {}
    
    @@past_english = ""
    @@present_english = ""

    class << self
    
        def build(options = {})
            # return "HI"
            @@root = options[:infinitive].split("na")[0]
            @@past_english = options[:past_english]
            @@present_english = options[:present_english]

            i_did
            we_did
            do_it
            you_did

            return @@hash
        end

        def i_did
            
            @@hash["i_masculine_did"] = {
                original: "میں "+@@root+ "ا تھا",
                roman: "Mein #{@@roman}a tha",
                translation: "I (Masculine)" + @@past_english + "."
            }

            @@hash["i_feminine_did"] = {
                original: "میں "+@@root+"ی تھی",
                roman: "Mein #{@@roman}a tha",
                translation: "I (Feminine)" + @@past_english + "."
            }
        end

        def i_am
            @@hash["i_masculine_am_doing"] = {
                original: "میں "+@@root+ " رہا ہوں",
                roman: "Mein #{@@roman}a tha",
                translation: "I (Masculine)" + @@present_english + "."
            }

            @@hash["i_feminine_am_doing"] = {
                original: "میں "+@@root+ " رہی ہوں",
                translation: "I (Feminine)" + @@present_english + "."
            }
        end

        def we_did            
            @@hash["we_did"] = {
                original:  "Hum #{@@root}ey they",
                translation: "We are " + @@past_english + "."
            }
        end

        def we_are_doing
            @@hash["we_did"] = {
                original:  "Hum #{@@root}ey they",
                translation: "We are " + @@present_english + "."
            }
        end

        def they_did            
            @@hash["they_did"] = {
                original:  "Woh #{@@root}ey they",
                translation: "They " + @@past_english + "."
            }
        end

        def you_did

            @@hash["you_masculine_did_it"] = {
                original:  "Woh #{@@root}ey they",
                translation: "You " + @@past_english + "."
            }

            @@hash["you_feminine_did_it"] = {
                original:  "Woh #{@@root}ee thi",
                translation: "You " + @@past_english + "."
            }

            @@hash["you_all_did_it_neutral"] = {
                original:  "Aap sab #{@@root}ee they",
                translation: "You all " + @@past_english + "."
            }

            
        end

        def do_it

            
            @@hash["do_it_informal_neutral"] = {
                original: "#{@@root}o",
                translation: @@present_english + "!"
            }

            @@hash["do_it_formal_neutral"] = {
                original: "#{@@root}ein",
                translation: @@present_english + "!"
            }

        end
    end
end