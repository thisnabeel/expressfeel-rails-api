class LanguageAdjectivesController < ApplicationController
  before_action :set_language_adjective, only: [:update, :destroy]

  # GET /language_adjectives
  # GET /language_adjectives.json
  def index
    @language_adjectives = LanguageAdjective.all
  end

  # GET /language_adjectives/1
  # GET /language_adjectives/1.json
  def show
    render json: Language.find(params[:id]).language_adjectives
  end

  # GET /language_adjectives/new
  def new
    @language_adjective = LanguageAdjective.new
  end

  # GET /language_adjectives/1/edit
  def edit
    @language = Language.find(params[:id])
  end

  def quiz
    render json: Language.find(params[:id]).language_adjectives.sample.blocks_quiz
  end
  # POST /language_adjectives
  # POST /language_adjectives.json
  def create
    @language_adjective = LanguageAdjective.new(language_adjective_params)
    @language = @language_adjective.language
  end

  # PATCH/PUT /language_adjectives/1
  # PATCH/PUT /language_adjectives/1.json
  def update
  end

  # DELETE /language_adjectives/1
  # DELETE /language_adjectives/1.json
  def destroy
    @language_adjective.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_language_adjective
      @language_adjective = LanguageAdjective.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def language_adjective_params
      params.require(:language_adjective).permit!
    end
end
