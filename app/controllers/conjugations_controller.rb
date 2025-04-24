class ConjugationsController < ApplicationController
  before_action :set_conjugation, only: [:show, :update, :destroy]

  # GET /conjugations
  # GET /conjugations.json
  def index
    @conjugations = Conjugation.all
  end

  def build
    if params[:puzzle] == true
      render status: 200, json: LanguageVerb.find(params[:language_verb_id]).blocks_quiz(Conjugation.find(params[:conjugation_id]))
    else
      render status: 200, json: Conjugation.find(params[:conjugation_id]).build(params[:language_verb_id])
    end
  end

  def sample
    phrases = Phrase.includes(:lesson, :language).where(ready: true).limit(20)
    render json: phrases, each_serializer: PhraseSerializer, just_phrase: true
  end

  # GET /conjugations/1
  # GET /conjugations/1.json
  def show
    render json: Conjugation.find(params[:id])
  end

  # GET /conjugations/new
  def new
    @conjugation = Conjugation.new
  end

  # GET /conjugations/1/edit
  def edit
    @language = Language.find(params[:id])
  end
  # POST /conjugations
  # POST /conjugations.json
  def create
    @conjugation = Conjugation.new(conjugation_params)
  end

  # PATCH/PUT /conjugations/1
  # PATCH/PUT /conjugations/1.json
  def update
  end

  # DELETE /conjugations/1
  # DELETE /conjugations/1.json
  def destroy
    @conjugation.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_conjugation
      @conjugation = Conjugation.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def conjugation_params
      params.require(:conjugation).permit!
    end
end
