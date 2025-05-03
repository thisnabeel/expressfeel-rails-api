class FactoriesController < ApplicationController
  before_action :set_factory, only: [:show, :update, :destroy, :sample_materials]

  # GET /factories
  # GET /factories.json
  def index
    @factories = Factory.all
  end

  # GET /factories/1
  # GET /factories/1.json
  def show
    render json: @factory
  end

  def fetch
    language = Language.find(params[:language_id])
    factory = language.factories.find_by(name: params[:name])
    render json: factory
  end

  # GET /factories/1/edit
  def edit
    @factories = Language.find(params[:id]).factories
    render json: @factories
  end

  def sample_materials
    materials = @factory.factory_materials.sample(params[:limit] || 1)
    render json: materials
  end

  # POST /factories
  # POST /factories.json
  def create
    @factory = Factory.new(factory_params)
    if @factory.save
      render json: @factory
    else
      render json: @factory.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /factories/1
  # PATCH/PUT /factories/1.json
  def update
    if @factory.update(factory_params)
      render json: @factory
    else
      render json: @factory.errors, status: :unprocessable_entity
    end
  end

  # DELETE /factories/1
  # DELETE /factories/1.json
  def destroy
    @factory.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_factory
      @factory = Factory.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def factory_params
      params.require(:factory).permit(:name, :materials_title, :materialable_type, :reactions_title, :position, :language_id, :active)
    end
end
