class BottleFeedbacksController < ApplicationController
  before_action :set_bottle_feedback, only: [:show, :edit, :update, :destroy]

  # GET /bottle_feedbacks
  # GET /bottle_feedbacks.json
  def index
    @bottle_feedbacks = BottleFeedback.all
  end

  # GET /bottle_feedbacks/1
  # GET /bottle_feedbacks/1.json
  def show
  end

  # GET /bottle_feedbacks/new
  def new
    @bottle_feedback = BottleFeedback.new
  end

  # GET /bottle_feedbacks/1/edit
  def edit
  end

  # POST /bottle_feedbacks
  # POST /bottle_feedbacks.json
  def create
    @bottle_feedback = BottleFeedback.new(bottle_feedback_params)
    render json: @bottle_feedback.save
  end

  # PATCH/PUT /bottle_feedbacks/1
  # PATCH/PUT /bottle_feedbacks/1.json
  def update
    render json: @bottle_feedback.update(bottle_feedback_params)
  end

  # DELETE /bottle_feedbacks/1
  # DELETE /bottle_feedbacks/1.json
  def destroy
    @bottle_feedback.destroy
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_bottle_feedback
      @bottle_feedback = BottleFeedback.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def bottle_feedback_params
      params.require(:bottle_feedback).permit(:body, :user_id)
    end
end
