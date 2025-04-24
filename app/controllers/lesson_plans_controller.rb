class LessonPlansController < ApplicationController
  before_action :set_lesson_plan, only: [:show, :edit, :update, :destroy]

  # GET /lesson_plans
  # GET /lesson_plans.json
  def index
    @lesson_plans = LessonPlan.all
  end

  # GET /lesson_plans/1
  # GET /lesson_plans/1.json
  def show
  end

  # GET /lesson_plans/new
  def new
    @lesson_plan = LessonPlan.new
  end

  # GET /lesson_plans/1/edit
  def edit
  end

  def quiz
    @lesson_plan = LessonPlan.find(params[:id])
    @language = @lesson_plan.language
    @random = @lesson_plan.random_quiz

  end

  # POST /lesson_plans
  # POST /lesson_plans.json
  def create
    @lesson_plan = LessonPlan.new(lesson_plan_params)
  end

  # PATCH/PUT /lesson_plans/1
  # PATCH/PUT /lesson_plans/1.json
  def update
  end

  # DELETE /lesson_plans/1
  # DELETE /lesson_plans/1.json
  def destroy
    @lesson_plan.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_lesson_plan
      @lesson_plan = LessonPlan.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def lesson_plan_params
      params.require(:lesson_plan).permit!
    end
end
