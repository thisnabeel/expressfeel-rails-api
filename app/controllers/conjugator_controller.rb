class ConjugatorController < ApplicationController
    def build
        lang = Language.find(params[:lang])
        if lang.title.include? "("
           title = lang.title.split("(")[1].split(")")[0] 
        else 
           title = lang.title
        end
        render status: 200, json: "Conjugator::#{title.capitalize}".constantize.build(params)
    end
    
    def tester

    end
end