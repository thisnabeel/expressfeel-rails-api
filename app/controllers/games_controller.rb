class GamesController < ApplicationController
  # before_filter :authenticate_teacher!, only: [:edit, :update, :destroy, :index]

  def index
    @games = Game.all
  end

  def new
    @game = Game.new
  end

  def show
    @game = Game.find(params[:id])
  end

  def create
    @game = Game.new(game_params)
  end

  def modify_game
    @game = Game.find(params[:game_id])
    @game.game_questions.destroy_all

    questions = params[:list]

    @game.update(title: params[:title])
    @game.update(description: params[:description])
    @game.update(game_type: params[:game_type])

    if questions.present?
      questions.each do |q|
        GameQuestion.create(
          game_id: @game.id,
          question: q["question"],
          choices: q["choices"],
          correct: q["correct"]
        )
      end
    end

    render json: @game
  end

  def edit
    @game = Game.find(params[:id])
  end

  def update
    @game = Game.find(params[:id])
    @game.update(game_params)
    render json: @game
  end

  # DELETE /flows/1
  # DELETE /flows/1.json
  def destroy
    @game = Game.find(params[:id])
    @game.destroy
  # 
  def find_verbs

    
    string = Verb.find_by_v_root(params[:id]).get_past_array
    render status: 200, json: {
      message: string,
    }.to_json

  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_game
      @game = Game.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def game_params
      params.require(:game).permit!
    end
end
