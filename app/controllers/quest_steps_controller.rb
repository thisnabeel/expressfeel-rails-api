# app/controllers/quest_steps_controller.rb
class QuestStepsController < ApplicationController
  before_action :set_quest

  def index
    language = nil
    if params[:language_title].present?
      language = Language.where('LOWER(title) = ?', params[:language_title].downcase.gsub("-", " ")).first
    end

    render json: {quest: @quest, steps: @quest.quest_steps.order(:position).map{|qs| QuestStepSerializer.new(qs, language: language)}}
  end

  def create
    quest_step = @quest.quest_steps.create!(quest_step_params)
    render json: quest_step
  end

  def update
    quest_step = @quest.quest_steps.find(params[:id])
    quest_step.update!(quest_step_params)
    render json: quest_step
  end

  def destroy
    quest_step = @quest.quest_steps.find(params[:id])
    quest_step.destroy
    head :no_content
  end

  def upload_image
    quest_step = QuestStep.find(params[:id])

    unless params[:file].present?
      return render json: { error: 'No file provided' }, status: :unprocessable_entity
    end

    file = params[:file].tempfile
    file_key = "quest_steps/#{quest_step.id}/image"

    uploader = ImageUploaderService.new
    image_url = uploader.upload_aws(file_key, file)

    quest_step.update!(image_url: image_url)

    render json: { image_url: image_url }, status: :ok
  end

  private

  def set_quest
    @quest = Quest.find(params[:quest_id])
  end

  def quest_step_params
    params.require(:quest_step).permit(:image_url, :thumbnail_url, :position, :body, :success_step_id, :failure_step_id, :quest_reward_id)
  end
end
