class FactoryDynamicOutputsController < ApplicationController
  before_action :set_factory_dynamic_output, only: %i[ show update destroy ]

  # GET /factory_dynamic_outputs
  # GET /factory_dynamic_outputs.json
  def index
    @factory_dynamic_outputs = FactoryDynamicOutput.all
  end

  # GET /factory_dynamic_outputs/1
  # GET /factory_dynamic_outputs/1.json
  def show
  end

  # POST /factory_dynamic_outputs
  # POST /factory_dynamic_outputs.json
  def create
    @factory_dynamic_output = FactoryDynamicOutput.new(factory_dynamic_output_params)

    if @factory_dynamic_output.save
      render json: @factory_dynamic_output, status: :created
    else
      render json: @factory_dynamic_output.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /factory_dynamic_outputs/1
  # PATCH/PUT /factory_dynamic_outputs/1.json
  def update
    if @factory_dynamic_output.update(factory_dynamic_output_params)
      render json: @factory_dynamic_output, status: :ok
    else
      render json: @factory_dynamic_output.errors, status: :unprocessable_entity
    end
  end

  # DELETE /factory_dynamic_outputs/1
  # DELETE /factory_dynamic_outputs/1.json
  def destroy
    @factory_dynamic_output.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_factory_dynamic_output
      @factory_dynamic_output = FactoryDynamicOutput.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def factory_dynamic_output_params
      params.require(:factory_dynamic_output).permit(:slug, :factory_dynamic_input_id, :initial_input_key, :position)
    end
end
