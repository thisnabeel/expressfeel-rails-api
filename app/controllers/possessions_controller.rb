class PossessionsController < ApplicationController
  before_action :set_possession, only: [:show, :update, :destroy]

  # GET /possessions
  # GET /possessions.json
  def index
    @possessions = Possession.all
  end

  def build
    if params[:puzzle] == true
      render status: 200, json: LanguageNoun.find(params[:language_noun_id]).blocks_quiz(Possession.find(params[:possession_id]))
    else
      render status: 200, json: Possession.find(params[:possession_id]).build(params[:language_noun_id])
    end
  end

  # GET /possessions/1
  # GET /possessions/1.json
  def show
    render json: Possession.find(params[:id])
  end

  # GET /possessions/new
  def new
    @possession = Possession.new
  end

  # GET /possessions/1/edit
  def edit
    render json: Language.find(params[:id]).possessions
  end

  # POST /possessions
  # POST /possessions.json
  def create
    @possession = Possession.new(possession_params)
  end

  # PATCH/PUT /possessions/1
  # PATCH/PUT /possessions/1.json
  def update
  end

  # DELETE /possessions/1
  # DELETE /possessions/1.json
  def destroy
    @possession.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_possession
      @possession = Possession.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def possession_params
      params.require(:possession).permit!
    end
end
