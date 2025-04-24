class PhraseInputsController < ApplicationController
  before_action :set_phrase_input, only: %i[ show update destroy save_payload]

  # GET /phrase_inputs
  # GET /phrase_inputs.json
  def index
    @phrase_inputs = PhraseInput.all
  end

  # GET /phrase_inputs/1
  # GET /phrase_inputs/1.json
  def show
  end

  def save_payload
    payload = @phrase_input.phrase_input_payloads.find_or_create_by(phrase_input_id: params[:phrase_input_id], factory_dynamic_input_id: params[:factory_dynamic_input_id])
    payload.update(phrase_input_payload_params)
    render json: payload
  end

  # POST /phrase_inputs
  # POST /phrase_inputs.json
  def create
    @phrase_input = PhraseInput.new(phrase_input_params)

    if @phrase_input.save
      render json: @phrase_input, status: :created
    else
      render json: @phrase_input.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /phrase_inputs/1
  # PATCH/PUT /phrase_inputs/1.json
  def update
    if @phrase_input.update(phrase_input_params)
      render json: @phrase_input, status: :ok
    else
      render json: @phrase_input.errors, status: :unprocessable_entity
    end
  end

  # DELETE /phrase_inputs/1
  # DELETE /phrase_inputs/1.json
  def destroy
    @phrase_input.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_phrase_input
      @phrase_input = PhraseInput.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def phrase_input_params
      params.require(:phrase_input).permit(:phrase_inputable_type, :phrase_inputable_id, :code, :position, :phrase_id)
    end

    def phrase_input_payload_params
      params.require(:phrase_input_payload).permit(:phrase_input_id, :phrase_payload_id, :factory_dynamic_input_id)
    end
end
