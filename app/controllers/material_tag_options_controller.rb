class MaterialTagOptionsController < ApplicationController
  before_action :set_material_tag_option, only: %i[ show update destroy ]

  # GET /material_tag_options
  # GET /material_tag_options.json
  def index
    @material_tag_options = MaterialTagOption.all
  end

  # GET /material_tag_options/1
  # GET /material_tag_options/1.json
  def show
  end

  # POST /material_tag_options
  # POST /material_tag_options.json
  def create
    @material_tag_option = MaterialTagOption.new(material_tag_option_params)

    if @material_tag_option.save
      render json: @material_tag_option, status: :created
    else
      render json: @material_tag_option.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /material_tag_options/1
  # PATCH/PUT /material_tag_options/1.json
  def update
    if @material_tag_option.update(material_tag_option_params)
      render json: @material_tag_option, status: :ok
    else
      render json: @material_tag_option.errors, status: :unprocessable_entity
    end
  end

  # DELETE /material_tag_options/1
  # DELETE /material_tag_options/1.json
  def destroy
    @material_tag_option.destroy!
  end

  def search
    tags = MaterialTagOption.where('title ILIKE ?', "%#{params[:q]}%").limit(10)
    render json: tags
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_material_tag_option
      @material_tag_option = MaterialTagOption.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def material_tag_option_params
      params.require(:material_tag_option).permit(:language_id, :title, :position)
    end
end
