class PhrasesController < ApplicationController
  before_action :set_phrase, only: [:show, :edit, :update, :destroy]

  # GET /phrases
  # GET /phrases.json
  def index
    @phrases = Phrase.all
  end

  # GET /phrases/1
  # GET /phrases/1.json
  def show
  end

  # GET /phrases/new
  def new
    @phrase = Phrase.new
  end

  # GET /phrases/1/edit
  def edit
  end

  # POST /phrases
  # POST /phrases.json
  def create
    @phrase = Phrase.new(phrase_params)
    if @phrase.save
      render json: @phrase, serializer: PhraseSerializer
    else
      render json: @phrase.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /phrases/1
  # PATCH/PUT /phrases/1.json
  def update
    if @phrase.update(phrase_params)
      render json: @phrase, serializer: PhraseSerializer
    else
      render json: @phrase.errors, status: :unprocessable_entity
    end

  end

  # DELETE /phrases/1
  # DELETE /phrases/1.json
  def destroy
    @phrase.destroy
  end

  def search

    @phrases = 
    Phrase
    .where('unaccent(title) ILIKE ? OR unaccent(translit) ILIKE ?', 
    "%#{params[:search]}%", "%#{params[:search]}%").pluck(:id)

   @phrases = @phrases + Phrase.search(params[:search]).pluck(:id)

   @phrases = Phrase.where(id: @phrases.uniq)

  end

  def test_from_list
    item = params[:list].sample
    if item["language_id"].present? && item["lesson_id"].present?
      render json: Phrase.where(language_id: item["language_id"], lesson_id: item["lesson_id"]).sample.id
    end
  end

  def build
    render status: 200, json: Phrase.find(params[:id]).build.to_json
  end

  def quiz
    phrase = Phrase.includes(
      :phrase_dynamics,
      phrase_factories: {
        factory: :factory_materials
      },
      phrase_inputs: [],
      language: [],
      lesson: [],
    ).find(params[:id])

    output = nil
    max_attempts = 10
    attempts = 0

    until output || attempts >= max_attempts
      begin
        output = BlocksQuiz.make(phrase)
      rescue => exception
        # Handle the exception, or simply retry
        puts "Error occurred: #{exception.message}"
      ensure
        attempts += 1
      end
    end

    output[:language] = phrase.language
    render json: output
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_phrase
      @phrase = Phrase.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def phrase_params
      params.require(:phrase).permit!
    end
end
