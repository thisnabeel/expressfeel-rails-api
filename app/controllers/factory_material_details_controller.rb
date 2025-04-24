class FactoryMaterialDetailsController < ApplicationController
  before_action :set_factory_material_detail, only: %i[ show update destroy ]

  # GET /factory_material_details
  # GET /factory_material_details.json
  def index
    @factory_material_details = FactoryMaterialDetail.all
  end

  # GET /factory_material_details/1
  # GET /factory_material_details/1.json
  def show
  end

  # POST /factory_material_details
  # POST /factory_material_details.json
  def create
    @factory_material_detail = FactoryMaterialDetail.find_or_create_by(slug: params[:slug], factory_material_id: params[:factory_material_id])

    if @factory_material_detail.update(factory_material_detail_params)
      render json: @factory_material_detail, status: :created
    else
      render json: @factory_material_detail.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /factory_material_details/1
  # PATCH/PUT /factory_material_details/1.json
  def update
    if @factory_material_detail.update(factory_material_detail_params)
      render json: @factory_material_detail, status: :ok
    else
      render json: @factory_material_detail.errors, status: :unprocessable_entity
    end
  end

  # DELETE /factory_material_details/1
  # DELETE /factory_material_details/1.json
  def destroy
    @factory_material_detail.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_factory_material_detail
      @factory_material_detail = FactoryMaterialDetail.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def factory_material_detail_params
      params.require(:factory_material_detail).permit(:factory_material_id, :slug, :value, :active, :category)
    end
end
