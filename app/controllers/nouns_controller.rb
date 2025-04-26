class NounsController < ApplicationController
  before_action :set_noun, only: [:show, :update, :destroy]

  # GET /nouns
  # GET /nouns.json
  def index
    @nouns = Noun.all.order("base ASC")
    render json: @nouns
  end

  def build
    if params[:puzzle] == true
      render status: 200, json: LanguageVerb.find(params[:language_verb_id]).blocks_quiz(Noun.find(params[:noun_id]))
    else
      render status: 200, json: Noun.find(params[:noun_id]).build(params[:language_verb_id])
    end
  end

  # GET /nouns/1
  # GET /nouns/1.json
  def show
    render json: Noun.find(params[:id])
  end

  # GET /nouns/new
  def new
    @noun = Noun.new
  end

  # GET /nouns/1/edit
  def edit
    @language = Language.find(params[:id])
  end

  # POST /nouns
  # POST /nouns.json
  def create
    @noun = Noun.new(noun_params)
    if @noun.save
      render json: @noun
    else
      render json: @noun.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /nouns/1
  # PATCH/PUT /nouns/1.json
  def update
    if @noun.update(noun_params)
      render json: @noun
    else
      render json: @noun.errors, status: :unprocessable_entity
    end
  end

  # DELETE /nouns/1
  # DELETE /nouns/1.json
  def destroy
    @noun.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_noun
      @noun = Noun.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def noun_params
      params.require(:noun).permit!
    end
end
