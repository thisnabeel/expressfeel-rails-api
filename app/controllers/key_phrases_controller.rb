class KeyPhrasesController < ApplicationController
  before_action :set_key_phrase, only: [:show, :edit, :update, :destroy]

  # GET /key_phrases
  # GET /key_phrases.json
  def index
    @key_phrases = KeyPhrase.all
  end

  # GET /key_phrases/1
  # GET /key_phrases/1.json
  def show
  end

  # GET /key_phrases/new
  def new
    @key_phrase = KeyPhrase.new
  end

  # GET /key_phrases/1/edit
  def edit
  end

  # POST /key_phrases
  # POST /key_phrases.json
  def create
    @key_phrase = KeyPhrase.new(key_phrase_params)
  end

  # PATCH/PUT /key_phrases/1
  # PATCH/PUT /key_phrases/1.json
  def update
  end

  # DELETE /key_phrases/1
  # DELETE /key_phrases/1.json
  def destroy
    @key_phrase.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_key_phrase
      @key_phrase = KeyPhrase.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def key_phrase_params
      params.require(:key_phrase).permit(:lesson_key, :phrase, :body, :recording, :tags, :position)
    end
end
