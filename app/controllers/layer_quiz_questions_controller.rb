class LayerQuizQuestionsController < ApplicationController
  include ApiAuthenticatable

  before_action :authenticate_api_admin!
  before_action :set_quiz, only: [:create]
  before_action :set_question, only: [:update, :destroy]

  # POST /layer_quizzes/:layer_quiz_id/layer_quiz_questions
  def create
    pos = @quiz.layer_quiz_questions.maximum(:position)
    next_pos = pos.nil? ? 0 : pos + 1
    q = @quiz.layer_quiz_questions.create!(question_params.merge(position: next_pos))
    render json: q.as_json_for_admin, status: :created
  end

  # PATCH /layer_quiz_questions/:id
  def update
    @question.update!(question_params)
    render json: @question.as_json_for_admin
  end

  # DELETE /layer_quiz_questions/:id
  def destroy
    @question.destroy!
    head :no_content
  end

  private

  def set_quiz
    @quiz = LayerQuiz.find(params[:layer_quiz_id])
  end

  def set_question
    @question = LayerQuizQuestion.find(params[:id])
  end

  def question_params
    params.require(:layer_quiz_question).permit(:original, :english, :position)
  end
end

