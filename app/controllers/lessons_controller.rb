class LessonsController < ApplicationController
  before_action :set_lesson, only: [:show, :edit, :update, :destroy]

  # GET /lessons
  # GET /lessons.json
  def index
    render json: Lesson.all.order("position ASC")
  end

  # POST /lessons/reorder
  def reorder
    params[:ids].each_with_index do |id, index|
      Lesson.where(id: id).update_all(position: index)
    end
    render json: { success: true }
  end


  def search_catalog
    render json: Lesson.where('objective LIKE ?', "%#{params[:search]}%")
  end

  def generate_scenarios
    expression = Lesson.find(params[:id]).objective
    render json: ChatGPT.send("Give me 10 scenarios where it would be helpful to know how to #{expression}. Using the template: 'You are... Say/Ask'")
  end

  def link_lesson
    @phrase = Phrase.create(
      lesson_id: params[:lesson_id], 
      language_id: params[:language_id],
      title: "New Phrase",
      formula: {
        original: [],
        roman: [],
        english: []
      }
    )
    render json: @phrase.lesson.attributes.merge(
        {
          phrases: [@phrase]
        }
      )
  end

  # GET /lessons/1
  # GET /lessons/1.json
  def show
  end

  # GET /lessons/new
  def new
    @lesson = Lesson.new
  end

  # GET /lessons/1/edit
  def edit
  end

  # POST /lessons
  # POST /lessons.json
  def create
    @lesson = Lesson.new(lesson_params)
    if @lesson.save
      render json: @lesson
    else
      render json: @lesson.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /lessons/1
  # PATCH/PUT /lessons/1.json
  def update
    if @lesson.update(lesson_params)
      render json: @lesson
    else
      render json: @lesson.errors, status: :unprocessable_entity
    end
  end

  # DELETE /lessons/1
  # DELETE /lessons/1.json
  def destroy
    @lesson.destroy
  end
# 
  def search
    if User.is_admin? current_user

        if params[:search] == ""
          @lessons = Lesson.all.where.not(objective: nil).sample(10)
        else
          @lessons = Lesson.all.where('objective ILIKE ? OR objective ILIKE ?', "%#{params[:search]}%", "%#{params[:search]}%")
        end

      else

        if params[:search] == ""
          @lessons = Lesson.joins(:phrases).uniq.all.where.not(objective: nil).sample(10)
        else
          @lessons = Lesson.joins(:phrases).uniq.all.where('objective ILIKE ? OR objective ILIKE ?', "%#{params[:search]}%", "%#{params[:search]}%")
        end

    end

    render json: @lessons
  end

  def phrases
    @phrases = Phrase.where(
      language_id: params[:language_id], 
      lesson_id: params[:lesson_id]
      )

    render json: @phrases, each_serializer: PhraseSerializer
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_lesson
      @lesson = Lesson.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def lesson_params
      params.require(:lesson).permit!
    end
end
