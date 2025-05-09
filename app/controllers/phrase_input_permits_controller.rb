class PhraseInputPermitsController < ApplicationController
  before_action :set_phrase_input_permit, only: %i[ show update destroy ]

  # GET /phrase_input_permits
  # GET /phrase_input_permits.json
  def index
    @phrase_input_permits = PhraseInputPermit.all
  end

  # GET /phrase_input_permits/1
  # GET /phrase_input_permits/1.json
  def show
  end

  # POST /phrase_input_permits
  # POST /phrase_input_permits.json
  def create
    @phrase_input_permit = PhraseInputPermit.new(phrase_input_permit_params)

    if @phrase_input_permit.save
      render json: @phrase_input_permit, status: :created
    else
      render json: @phrase_input_permit.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /phrase_input_permits/1
  # PATCH/PUT /phrase_input_permits/1.json
  def update
    if @phrase_input_permit.update(phrase_input_permit_params)
      render json: @phrase_input_permit, status: :ok
    else
      render json: @phrase_input_permit.errors, status: :unprocessable_entity
    end
  end

  # DELETE /phrase_input_permits/1
  # DELETE /phrase_input_permits/1.json
  def destroy
    @phrase_input_permit.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_phrase_input_permit
      @phrase_input_permit = PhraseInputPermit.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def phrase_input_permit_params
      params.require(:phrase_input_permit).permit(:phrase_input_id, :material_tag_option_id, :permit, :factory_material_id)
    end
end
