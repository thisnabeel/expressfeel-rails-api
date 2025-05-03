class AdjectivesController < ApplicationController
  before_action :set_adjective, only: [:show, :update, :destroy]

  # GET /adjectives
  # GET /adjectives.json
  def index
    @adjectives = Adjective.all.order("created_at DESC")
    render json: @adjectives
  end

  # GET /adjectives/1
  # GET /adjectives/1.json
  def show
    render json: Adjective.find(params[:id])
  end

  # GET /adjectives/new
  def new
    @adjective = Adjective.new
  end

  # GET /adjectives/1/edit
  def edit
    @language = Language.find(params[:id])
  end

  # POST /adjectives
  # POST /adjectives.json
  def create
    @adjective = Adjective.new(adjective_params)
    if @adjective.save
      render json: @adjective
    else
      render json: @adjective.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /adjectives/1
  # PATCH/PUT /adjectives/1.json
  def update
    if @adjective.update(adjective_params)
      render json: @adjective
    else
      render json: @adjective.errors, status: :unprocessable_entity
    end
  end

  # DELETE /adjectives/1
  # DELETE /adjectives/1.json
  def destroy
    @adjective.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_adjective
      @adjective = Adjective.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def adjective_params
      params.require(:adjective).permit!
    end
end
