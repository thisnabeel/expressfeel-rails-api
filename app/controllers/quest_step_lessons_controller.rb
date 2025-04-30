class QuestStepLessonsController < ApplicationController
  before_action :set_quest_step_lesson, only: %i[ show update destroy ]

  # GET /quest_step_lessons
  # GET /quest_step_lessons.json
  def index
    @quest_step_lessons = QuestStepLesson.all
  end

  # GET /quest_step_lessons/1
  # GET /quest_step_lessons/1.json
  def show
  end

  # POST /quest_step_lessons
  # POST /quest_step_lessons.json
  def create
    @quest_step_lesson = QuestStepLesson.new(quest_step_lesson_params)

    if @quest_step_lesson.save
      render json: @quest_step_lesson, status: :created
    else
      render json: @quest_step_lesson.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /quest_step_lessons/1
  # PATCH/PUT /quest_step_lessons/1.json
  def update
    if @quest_step_lesson.update(quest_step_lesson_params)
      render :show, status: :ok, location: @quest_step_lesson
    else
      render json: @quest_step_lesson.errors, status: :unprocessable_entity
    end
  end

  # DELETE /quest_step_lessons/1
  # DELETE /quest_step_lessons/1.json
  def destroy
    @quest_step_lesson.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_quest_step_lesson
      @quest_step_lesson = QuestStepLesson.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def quest_step_lesson_params
      params.require(:quest_step_lesson).permit(:lesson_id, :quest_step_id)
    end
end
