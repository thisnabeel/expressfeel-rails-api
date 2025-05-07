class FactoryMaterialsController < ApplicationController
  before_action :set_factory_material, only: [:show, :edit, :update, :destroy, :suggest_details]

  # GET /factory_materials
  # GET /factory_materials.json
  def index
    @factory_materials = FactoryMaterial.all
  end

  # GET /factory_materials/1
  # GET /factory_materials/1.json
  def show
  end

  def search
    results = []
    query = params["query"]
    inputable_type = params["phrase_input"]["phrase_inputable_type"]
    inputable_id = params["phrase_input"]["phrase_inputable_id"]
    if inputable_type === "Factory"
      model = inputable_type.constantize.find(inputable_id)
      english_model = model.materialable_type.constantize
      model.factory_material_details.where("value LIKE ?", "%#{query}%" ).each do |item|
        results << item.factory_material
      end

      if results.empty?
        columns = english_model.column_names - %w[id created_at updated_at]
        conditions = columns.map { |col| "#{col} ILIKE :q" }.join(" OR ")
        english_results = english_model.where(conditions, q: "%#{params[:query]}%")
        if english_results.present?
          model.factory_materials.where(materialable_id: english_results.pluck(:id)).each do |item|
            results << item
          end
        end
      end

    end
    render json: results, each_serializer: FactoryMaterialSerializer
  end

  def suggest_details
    factory = @factory_material.factory
    language = factory.language
    rules = factory.factory_rules.pluck(:slug)
    current = {
      english: @factory_material.materialable.attributes.except("id", "created_at", "updated_at"),
      details: {}
    }
    

    siblings = factory
      .factory_materials
      .where.not(id: @factory_material.id)
      .sample(3)
      .map do |sibling|
        {
          english: sibling.materialable.attributes.except("id", "created_at", "updated_at"),
          details: sibling.factory_material_details
                          .where(slug: rules)
                          .pluck(:slug, :value)
                          .to_h
        }
      end

    prompt = "Act as a #{language.title} language teacher. We have these populated #{siblings.to_json}. Now give me the details for this #{current}"
    render json: WizardService.ask(prompt)
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
