class ReactionsController < ApplicationController
  before_action :set_reaction, only: [:show, :edit, :update, :destroy]

  # GET /reactions
  # GET /reactions.json
  def index
    @reactions = Reaction.all
  end

  def build
    if params[:puzzle] == true
      render status: 200, json: FactoryMaterial.find(params[:factory_material_id]).blocks_quiz(Reaction.find(params[:reaction_id]))
    else
      render status: 200, json: Reaction.find(params[:reaction_id]).build(params[:factory_material_id])
    end
  end


  # GET /reactions/1
  # GET /reactions/1.json
  def show
  end

  # GET /reactions/new
  def new
    @reaction = Reaction.new
  end

  # GET /reactions/1/edit
  def edit
  end

  def quiz
    render json: BlocksQuiz.make(Reaction.find(params[:id]))
  end

  # POST /reactions
  # POST /reactions.json
  def create
    @reaction = Reaction.new(reaction_params)
  end

  # PATCH/PUT /reactions/1
  # PATCH/PUT /reactions/1.json
  def update
  end

  # DELETE /reactions/1
  # DELETE /reactions/1.json
  def destroy
    @reaction.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_reaction
      @reaction = Reaction.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def reaction_params
      params.require(:reaction).permit!
    end
end
