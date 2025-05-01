class QuestStepLessonPayloadsController < ApplicationController
  before_action :set_quest_step_lesson_payload, only: %i[ show update destroy ]

  # GET /quest_step_lesson_payloads
  # GET /quest_step_lesson_payloads.json
  def index
    @quest_step_lesson_payloads = QuestStepLessonPayload.all
  end

  # GET /quest_step_lesson_payloads/1
  # GET /quest_step_lesson_payloads/1.json
  def show
  end

  # POST /quest_step_lesson_payloads
  # POST /quest_step_lesson_payloads.json
  def create
    @quest_step_lesson_payload = QuestStepLessonPayload.new(quest_step_lesson_payload_params)

    if @quest_step_lesson_payload.save
      render json: @quest_step_lesson_payload, status: :created, location: @quest_step_lesson_payload
    else
      render json: @quest_step_lesson_payload.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /quest_step_lesson_payloads/1
  # PATCH/PUT /quest_step_lesson_payloads/1.json
  def update
    if @quest_step_lesson_payload.update(quest_step_lesson_payload_params)
      render :show, status: :ok, location: @quest_step_lesson_payload
    else
      render json: @quest_step_lesson_payload.errors, status: :unprocessable_entity
    end
  end

  # DELETE /quest_step_lesson_payloads/1
  # DELETE /quest_step_lesson_payloads/1.json
  def destroy
    @quest_step_lesson_payload.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_quest_step_lesson_payload
      @quest_step_lesson_payload = QuestStepLessonPayload.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def quest_step_lesson_payload_params
      params.require(:quest_step_lesson_payload).permit(:quest_step_lesson_id, :materialable_type, :materialable_id)
    end
end
