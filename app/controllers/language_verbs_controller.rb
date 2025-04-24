class LanguageVerbsController < ApplicationController
  before_action :set_language_verb, only: [:update, :destroy]

  # GET /language_verbs
  # GET /language_verbs.json
  def index
    @language_verbs = LanguageVerb.all
  end

  # GET /language_verbs/1
  # GET /language_verbs/1.json
  def show
    render json: Language.find(params[:id]).language_verbs
  end

  # GET /language_verbs/new
  def new
    @language_verb = LanguageVerb.new
  end

  # GET /language_verbs/1/edit
  def edit
    @language = Language.find(params[:id])
  end

  def quiz
    render json: Language.find(params[:id]).language_verbs.sample.blocks_quiz
  end
  # POST /language_verbs
  # POST /language_verbs.json
  def create
    @language_verb = LanguageVerb.new(language_verb_params)
    @language = @language_verb.language
  end

  # PATCH/PUT /language_verbs/1
  # PATCH/PUT /language_verbs/1.json
  def update
  end

  # DELETE /language_verbs/1
  # DELETE /language_verbs/1.json
  def destroy
    @language_verb.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_language_verb
      @language_verb = LanguageVerb.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def language_verb_params
      params.require(:language_verb).permit!
    end
end
