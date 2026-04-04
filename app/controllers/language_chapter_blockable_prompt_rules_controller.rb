class LanguageChapterBlockablePromptRulesController < ApplicationController
  include ApiAuthenticatable

  before_action :set_parent_scope, only: [:create]
  before_action :set_rule, only: [:update, :destroy]
  before_action :authenticate_api_admin!

  def create
    next_pos = @parent_rules.maximum(:position).to_i + 1
    rule = @parent_rules.create!(rule_params.merge(position: next_pos))
    render json: { language_chapter_blockable_prompt_rule: serialize_rule(rule) }, status: :created
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.record.errors.full_messages.join(", ") }, status: :unprocessable_entity
  end

  def update
    @rule.update!(rule_params)
    render json: { language_chapter_blockable_prompt_rule: serialize_rule(@rule.reload) }
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.record.errors.full_messages.join(", ") }, status: :unprocessable_entity
  end

  def destroy
    @rule.destroy!
    head :no_content
  end

  private

  def set_parent_scope
    @parent_rules = if params[:language_chapter_blockable_set_id].present?
                      LanguageChapterBlockableSet.find(params[:language_chapter_blockable_set_id])
                        .language_chapter_blockable_prompt_rules
                    elsif params[:language_chapter_blockable_option_id].present?
                      LanguageChapterBlockableOption.find(params[:language_chapter_blockable_option_id])
                        .language_chapter_blockable_prompt_rules
                    end
    return if @parent_rules

    render json: { error: "Missing blockable set or option" }, status: :bad_request
  end

  def set_rule
    @rule = LanguageChapterBlockablePromptRule.find(params[:id])
  end

  def rule_params
    params.require(:language_chapter_blockable_prompt_rule).permit(:body, :position)
  end

  def serialize_rule(r)
    {
      id: r.id,
      body: r.body,
      position: r.position,
      language_chapter_blockable_set_id: r.language_chapter_blockable_set_id,
      language_chapter_blockable_option_id: r.language_chapter_blockable_option_id
    }
  end
end
