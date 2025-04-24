class FactoryMaterialsController < ApplicationController
  before_action :set_factory_material, only: [:show, :edit, :update, :destroy]

  # GET /factory_materials
  # GET /factory_materials.json
  def index
    @factory_materials = FactoryMaterial.all
  end

  # GET /factory_materials/1
  # GET /factory_materials/1.json
  def show
  end

  def by_param
    render json: Language.find(params[:id]).factories.find_by(materials_title: params[:param]).factory_materials
  end

  def by_factory
    render json: Factory.find(params[:id]).factory_materials, each_serializer: FactoryMaterialSerializer
  end

  # GET /factory_materials/new
  def new
    @factory_material = FactoryMaterial.new
  end

  # GET /factory_materials/1/edit
  def edit
  end

  # POST /factory_materials
  # POST /factory_materials.json
  def create
    @factory_material = FactoryMaterial.new(factory_material_params)
    if @factory_material.save!
      render json: @factory_material
    else
      render json: @factory_material.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /factory_materials/1
  # PATCH/PUT /factory_materials/1.json
  def update
    if @factory_material.update(factory_material_params)
      render json: @factory_material
    else
      render json: @factory_material.errors, status: :unprocessable_entity
    end
  end

  # DELETE /factory_materials/1
  # DELETE /factory_materials/1.json
  def destroy
    @factory_material.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_factory_material
      @factory_material = FactoryMaterial.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def factory_material_params
      params.require(:factory_material).permit!
    end
end
