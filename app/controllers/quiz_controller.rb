class QuizController < ApplicationController
  def quiz
    @language = Language.find(params[:id])
    @random = @language.random_quiz
  end

  def get_random_quiz
    @language = Language.find(params[:id])
    @random = @language.random_quiz
    render json: @random
  end

  def get_lesson_plan_quiz
    lp = LessonPlan.find(params[:id])
    @random = lp.random_quiz
    @language = lp.language
    render json: @random
  end
end
