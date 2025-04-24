class PortfolioController < ApplicationController
    def home
        
        @user = User.find_by_username(params[:username].split("@")[1])
        if !@user.present?
            redirect_to "/"
        end
        @passport_phrases = @user.passport_phrases.order("created_at DESC")
    end

    def update_mission
        passport_phrase = params[:passport_phrase]
        pp = PassportPhrase.where(user_id: passport_phrase[:user_id], phrase_id: passport_phrase[:phrase_id])
        if pp.present?
            pp.first.update(updated_at: Time.now)
            render status: 200, json: {
                title: "Stamp Renewed",
                message: "Your stamp has been renewed!",
            }.to_json
        else
            @passport_phrase = PassportPhrase.create(passport_phrase_params)
            render status: 200, json: {
                title: "+10 Points",
                message: "This Expression is now Stamped to your Passport!",
            }.to_json
        end
    end

    private
        # Never trust parameters from the scary internet, only allow the white list through.
        def passport_phrase_params
            params.require(:passport_phrase).permit(:user_id, :phrase_id, :language_id)
        end
end
