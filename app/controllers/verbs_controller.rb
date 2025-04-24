class VerbsController < ApplicationController
  before_action :set_verb, only: [:show, :edit, :update, :destroy]

  # GET /verbs
  # GET /verbs.json
  def index
    @verbs = Verb.all
    render json: @verbs
  end

  # GET /verbs/1
  # GET /verbs/1.json
  def show
  end

  # GET /verbs/new
  def new
    @verb = Verb.new
  end

  # GET /verbs/1/edit
  def edit
  end

  # POST /verbs
  # POST /verbs.json
  def create
    @verb = Verb.new(verb_params)
    if @verb.save
      render json: @verb
    else
      render json: @verb.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /verbs/1
  # PATCH/PUT /verbs/1.json
  def update
    if @verb.update(verb_params)
      render json: @verb
    else
      render json: @verb.errors, status: :unprocessable_entity
    end
  end

  # DELETE /verbs/1
  # DELETE /verbs/1.json
  def destroy
    @verb.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_verb
      @verb = Verb.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def verb_params
      params.require(:verb).permit(:infinitive, :category, :past, :present)
    end
end
