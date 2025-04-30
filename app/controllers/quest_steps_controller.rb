# app/controllers/quest_steps_controller.rb
class QuestStepsController < ApplicationController
  before_action :set_quest

  def index
    render json: {quest: @quest, steps: @quest.quest_steps.order(:position)}
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

  private

  def set_quest
    @quest = Quest.find(params[:quest_id])
  end

  def quest_step_params
    params.require(:quest_step).permit(:image_url, :thumbnail_url, :position, :body, :success_step_id, :failure_step_id, :quest_reward_id)
  end
end
