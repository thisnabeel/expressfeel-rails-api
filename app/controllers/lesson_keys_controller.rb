class LessonKeysController < ApplicationController
  def save

    if LessonKey.where(lesson_id: params[:lesson_id]).find_by_language_id(params[:language_id]).present?
      lk = LessonKey.where(lesson_id: params[:lesson_id]).find_by_language_id(params[:language_id])
    else
      lk = LessonKey.create(
          lesson_id: params[:lesson_id],
          language_id: params[:language_id],
      )
    end

    lk.update(folder: params[:folder])

    render json: lk

    # render json: params

  end

  def find 
      if LessonKey.where(lesson_id: params[:lesson_id]).find_by_language_id(params[:language_id]).present?
        lk = LessonKey.where(lesson_id: params[:lesson_id]).find_by_language_id(params[:language_id])

        if lk.folder.present?
          render json: lk
        else
          render status: 404, json: {
            message: lk,
          }.to_json
        end

      else
        render status: 404, json: {
          message: "Empty!",
        }.to_json
      end

  end

  def create
    @lesson_key = LessonKey.new(lesson_key_params)
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_lesson_key
      @lesson_key = LessonKey.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def lesson_key_params
      params.require(:lesson_key).permit!
    end
end
