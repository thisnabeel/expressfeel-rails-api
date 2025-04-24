class PhraseInputPayloadsController < ApplicationController
  before_action :set_phrase_input_payload, only: %i[ show update destroy ]

  # GET /phrase_input_payloads
  # GET /phrase_input_payloads.json
  def index
    @phrase_input_payloads = PhraseInputPayload.all
  end

  # GET /phrase_input_payloads/1
  # GET /phrase_input_payloads/1.json
  def show
  end

  # POST /phrase_input_payloads
  # POST /phrase_input_payloads.json
  def create
    @phrase_input_payload = PhraseInputPayload.new(phrase_input_payload_params)

    if @phrase_input_payload.save
      render :show, status: :created, location: @phrase_input_payload
    else
      render json: @phrase_input_payload.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /phrase_input_payloads/1
  # PATCH/PUT /phrase_input_payloads/1.json
  def update
    if @phrase_input_payload.update(phrase_input_payload_params)
      render :show, status: :ok, location: @phrase_input_payload
    else
      render json: @phrase_input_payload.errors, status: :unprocessable_entity
    end
  end

  # DELETE /phrase_input_payloads/1
  # DELETE /phrase_input_payloads/1.json
  def destroy
    @phrase_input_payload.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_phrase_input_payload
      @phrase_input_payload = PhraseInputPayload.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def phrase_input_payload_params
      params.require(:phrase_input_payload).permit(:phrase_input_id, :phrase_payload_id, :factory_dynamic_input_id)
    end
end
