class LanguageNounsController < ApplicationController
  before_action :set_language_noun, only: [:update, :destroy]

  # GET /language_nouns
  # GET /language_nouns.json
  def index
    @language_nouns = LanguageNoun.all
  end

  # GET /language_nouns/1
  # GET /language_nouns/1.json
  def show
    render json: Language.find(params[:id]).language_nouns
  end

  # GET /language_nouns/new
  def new
    @language_noun = LanguageNoun.new
  end

  # GET /language_nouns/1/edit
  def edit
    @language = Language.find(params[:id])

  def quiz
    render json: Language.find(params[:id]).language_nouns.sample.blocks_quiz
  end
  # POST /language_nouns
  # POST /language_nouns.json
  def create
    @language_noun = LanguageNoun.new(language_noun_params)
    @language = @language_noun.language
  end

  # PATCH/PUT /language_nouns/1
  # PATCH/PUT /language_nouns/1.json
  def update
  end

  # DELETE /language_nouns/1
  # DELETE /language_nouns/1.json
  def destroy
    @language_noun.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_language_noun
      @language_noun = LanguageNoun.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def language_noun_params
      params.require(:language_noun).permit!
    end
end
