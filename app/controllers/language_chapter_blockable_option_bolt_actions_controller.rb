class LanguageChapterBlockableOptionBoltActionsController < ApplicationController
  include ApiAuthenticatable

  before_action :set_parent_scope, only: [:create]
  before_action :set_bolt_action, only: [:update, :destroy]
  before_action :authenticate_api_admin!

  def create
    next_pos = @parent_actions.maximum(:position).to_i + 1
    action = @parent_actions.create!(action_params.merge(position: next_pos))
    render json: { language_chapter_blockable_option_bolt_action: serialize_action(action) }, status: :created
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.record.errors.full_messages.join(", ") }, status: :unprocessable_entity
  end

  def update
    @bolt_action.update!(action_params)
    render json: { language_chapter_blockable_option_bolt_action: serialize_action(@bolt_action.reload) }
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.record.errors.full_messages.join(", ") }, status: :unprocessable_entity
  end

  def destroy
    @bolt_action.destroy!
    head :no_content
  end

  private

  def set_parent_scope
    @parent_actions = LanguageChapterBlockableOption.find(params[:language_chapter_blockable_option_id])
      .language_chapter_blockable_option_bolt_actions
  end

  def set_bolt_action
    @bolt_action = LanguageChapterBlockableOptionBoltAction.find(params[:id])
  end

  def action_params
    params.require(:language_chapter_blockable_option_bolt_action).permit(:prompt, :position)
  end

  def serialize_action(a)
    {
      id: a.id,
      prompt: a.prompt,
      position: a.position,
      language_chapter_blockable_option_id: a.language_chapter_blockable_option_id
    }
  end
end
