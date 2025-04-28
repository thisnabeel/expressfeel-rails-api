class MaterialTagsController < ApplicationController
  before_action :set_material_tag, only: %i[ show update destroy ]

  # GET /material_tags
  # GET /material_tags.json
  def index
    @material_tags = MaterialTag.all
  end

  # GET /material_tags/1
  # GET /material_tags/1.json
  def show
  end

  # POST /material_tags
  # POST /material_tags.json
  def create
    @material_tag = MaterialTag.new(material_tag_params)

    if @material_tag.save
      render json: @material_tag, status: :created
    else
      render json: @material_tag.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /material_tags/1
  # PATCH/PUT /material_tags/1.json
  def update
    if @material_tag.update(material_tag_params)
      render json: @material_tag, status: :ok
    else
      render json: @material_tag.errors, status: :unprocessable_entity
    end
  end

  # DELETE /material_tags/1
  # DELETE /material_tags/1.json
  def destroy
    @material_tag.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_material_tag
      @material_tag = MaterialTag.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def material_tag_params
      params.require(:material_tag).permit(:material_tag_option_id, :factory_material_id)
    end
end
