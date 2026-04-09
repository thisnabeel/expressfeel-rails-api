class LanguageChapterBlockableOptionsController < ApplicationController
  include ApiAuthenticatable

  before_action :set_blockable_set, only: [:index, :create]
  before_action :set_option, only: [:update, :destroy]
  before_action :authenticate_api_admin!

  def index
    options = @blockable_set.language_chapter_blockable_options.ordered.includes(
      :language_chapter_blockable_prompt_rules,
      :language_chapter_blockable_option_bolt_actions
    )
    render json: {
      language_chapter_blockable_options: options.map { |o| serialize_option(o) }
    }
  end

  def create
    next_pos = @blockable_set.language_chapter_blockable_options.maximum(:position).to_i + 1
    option = @blockable_set.language_chapter_blockable_options.create!(
      option_params.merge(position: next_pos)
    )
    render json: { language_chapter_blockable_option: serialize_option(option) }, status: :created
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.record.errors.full_messages.join(", ") }, status: :unprocessable_entity
  end

  def update
    @option.update!(option_params)
    render json: { language_chapter_blockable_option: serialize_option(@option.reload) }
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.record.errors.full_messages.join(", ") }, status: :unprocessable_entity
  end

  def destroy
    @option.destroy!
    head :no_content
  end

  private

  def set_blockable_set
    @blockable_set = LanguageChapterBlockableSet.find(params[:language_chapter_blockable_set_id])
  end

  def set_option
    @option = LanguageChapterBlockableOption.find(params[:id])
  end

  def option_params
    params.require(:language_chapter_blockable_option).permit(:title, :description, :display, :position)
  end

  def serialize_option(o)
    {
      id: o.id,
      language_chapter_blockable_set_id: o.language_chapter_blockable_set_id,
      title: o.title,
      description: o.description,
      display: o.display,
      position: o.position,
      prompt_rules: o.language_chapter_blockable_prompt_rules.ordered.map { |r|
        { id: r.id, body: r.body, position: r.position }
      },
      bolt_actions: o.language_chapter_blockable_option_bolt_actions.map { |a|
        { id: a.id, prompt: a.prompt, position: a.position }
      }
    }
  end
end
