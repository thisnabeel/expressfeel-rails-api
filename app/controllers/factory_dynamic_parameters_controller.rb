class FactoryDynamicParametersController < ApplicationController
  before_action :set_factory_dynamic_parameter, only: %i[ show edit update destroy ]

  # GET /factory_dynamic_parameters or /factory_dynamic_parameters.json
  def index
    @factory_dynamic_parameters = FactoryDynamicParameter.all
    render json: @factory_dynamic_parameters
  end

  # GET /factory_dynamic_parameters/1 or /factory_dynamic_parameters/1.json
  def show
  end

  # GET /factory_dynamic_parameters/new
  def new
    @factory_dynamic_parameter = FactoryDynamicParameter.new
  end

  # GET /factory_dynamic_parameters/1/edit
  def edit
  end

  # POST /factory_dynamic_parameters or /factory_dynamic_parameters.json
  def create
    @factory_dynamic_parameter = FactoryDynamicParameter.new(factory_dynamic_parameter_params)
    if @factory_dynamic_parameter.save
      render json: @factory_dynamic_parameter
    else
      render json: @factory_dynamic_parameter.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /factory_dynamic_parameters/1 or /factory_dynamic_parameters/1.json
  def update
    if @factory_dynamic_parameter.update(factory_dynamic_parameter_params)
      render json: @factory_dynamic_parameter
    else
      render json: @factory_dynamic_parameter.errors, status: :unprocessable_entity
    end
  end

  # DELETE /factory_dynamic_parameters/1 or /factory_dynamic_parameters/1.json
  def destroy
    @factory_dynamic_parameter.destroy
  end
  

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_factory_dynamic_parameter
      @factory_dynamic_parameter = FactoryDynamicParameter.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def factory_dynamic_parameter_params
      params.require(:factory_dynamic_parameter).permit!
    end
end
