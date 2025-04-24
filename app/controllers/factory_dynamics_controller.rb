class FactoryDynamicsController < ApplicationController
  before_action :set_factory_dynamic, only: [:show, :edit, :update, :destroy, :quiz, :build]

  # GET /factory_dynamics
  # GET /factory_dynamics.json
  def index
    @factory_dynamics = FactoryDynamic.all
    render json: @factory_dynamics
  end

  # GET /factory_dynamics/1
  # GET /factory_dynamics/1.json
  def show
    render json: @factory_dynamic, serializer: FactoryDynamicSerializer
  end

  def by_language
    @factory_dynamics = Language.find(params[:id]).factory_dynamics
    render json: @factory_dynamics, each_serializer: FactoryDynamicSerializer
  end

  def quiz
    render json: @factory_dynamic.quiz
  end

  def run
    items_manifest = params[:inputs]
    
    dynamic = FactoryDynamic.find(params[:dynamic]["id"])
    language = dynamic.factory.language

    options = {
      language: language,
      items_manifest: items_manifest,
      dynamic: dynamic
    }
    render json: DynamicBuilder.build(options)
    # render json: {
    #   steps_js: params[:steps],
    #   steps_ruby: dynamic.steps
    # }
  end

  # GET /factory_dynamics/new



  # GET /factory_dynamics/1/edit
  def edit
  end

  # POST /factory_dynamics
  # POST /factory_dynamics.json
  def create
    @factory_dynamic = FactoryDynamic.new(factory_dynamic_params)
    if @factory_dynamic.save
      render json: @factory_dynamic, serializer: FactoryDynamicSerializer
    else
      render json: @factory_dynamic.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /factory_dynamics/1
  # PATCH/PUT /factory_dynamics/1.json
  def update
    if @factory_dynamic.update(factory_dynamic_params)
      render json: @factory_dynamic, serializer: FactoryDynamicSerializer
    else
      render json: @factory_dynamic.errors, status: :unprocessable_entity
    end
  end

  # DELETE /factory_dynamics/1
  # DELETE /factory_dynamics/1.json
  def destroy
    @factory_dynamic.destroy
  end

  # app/controllers/factory_dynamics_controller.rb
  def build
    config = params[:config]
    inputs = params[:inputs]
    funnels = params[:funnels]
    # funnels["verb"]["factory_material"]["factory_material_details"]
    # binding.pry
    render json: @factory_dynamic.build
  end

  private


    # Use callbacks to share common setup or constraints between actions.
    def set_factory_dynamic
      @factory_dynamic = FactoryDynamic.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def factory_dynamic_params
      params.require(:factory_dynamic).permit!
    end
end
