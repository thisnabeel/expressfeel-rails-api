class FactoryDynamicInputsController < ApplicationController
  before_action :set_factory_dynamic_input, only: %i[ show update destroy ]

  # GET /factory_dynamic_inputs
  # GET /factory_dynamic_inputs.json
  def index
    @factory_dynamic_inputs = FactoryDynamicInput.all
  end

  # GET /factory_dynamic_inputs/1
  # GET /factory_dynamic_inputs/1.json
  def show
  end

  # POST /factory_dynamic_inputs
  # POST /factory_dynamic_inputs.json
  def create
    @factory_dynamic_input = FactoryDynamicInput.new(factory_dynamic_input_params)
    if @factory_dynamic_input.save
      render json: @factory_dynamic_input
    else
      render json: @factory_dynamic_input.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /factory_dynamic_inputs/1
  # PATCH/PUT /factory_dynamic_inputs/1.json
  def update
    if @factory_dynamic_input.update(factory_dynamic_input_params)
      render :show, status: :ok, location: @factory_dynamic_input
    else
      render json: @factory_dynamic_input.errors, status: :unprocessable_entity
    end
  end

  # DELETE /factory_dynamic_inputs/1
  # DELETE /factory_dynamic_inputs/1.json
  def destroy
    @factory_dynamic_input.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_factory_dynamic_input
      @factory_dynamic_input = FactoryDynamicInput.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def factory_dynamic_input_params
      params.require(:factory_dynamic_input).permit(:slug, :factory_id, :position, :selected_rule, :factory_dynamic_id)
    end
end
