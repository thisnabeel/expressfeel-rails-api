class LayerItemQuizAnswersController < ApplicationController
  include ApiAuthenticatable

  before_action :authenticate_api_admin!
  before_action :set_question, only: [:create]
  before_action :set_answer, only: [:update, :destroy]

  # POST /layer_quiz_questions/:layer_quiz_question_id/layer_item_quiz_answers
  def create
    pos = @question.layer_item_quiz_answers.maximum(:position)
    next_pos = pos.nil? ? 1 : pos + 1
    a = @question.layer_item_quiz_answers.create!(answer_params.merge(position: next_pos))
    render json: a.as_json_for_admin, status: :created
  end

  # PATCH /layer_item_quiz_answers/:id
  def update
    @answer.update!(answer_params)
    render json: @answer.as_json_for_admin
  end

  # DELETE /layer_item_quiz_answers/:id
  def destroy
    @answer.destroy!
    head :no_content
  end

  private

  def set_question
    @question = LayerQuizQuestion.find(params[:layer_quiz_question_id])
  end

  def set_answer
    @answer = LayerItemQuizAnswer.find(params[:id])
  end

  def answer_params
    params.require(:layer_item_quiz_answer).permit(:original, :english, :position, :correct)
  end
end

