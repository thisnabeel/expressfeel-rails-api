class LanguageChapterBlockableSetsController < ApplicationController
  include ApiAuthenticatable

  before_action :set_language, only: [:index, :create]
  before_action :set_blockable_set, only: [:update, :destroy]
  before_action :authenticate_api_admin!

  def index
    sets = @language.language_chapter_blockable_sets.ordered.includes(
      :language_chapter_blockable_prompt_rules,
      :language_chapter_blockable_options
    )
    render json: {
      language_chapter_blockable_sets: sets.map { |s| serialize_set(s) }
    }
  end

  def create
    next_pos = @language.language_chapter_blockable_sets.maximum(:position).to_i + 1
    record = @language.language_chapter_blockable_sets.create!(
      blockable_set_params.merge(position: next_pos)
    )
    render json: { language_chapter_blockable_set: serialize_set(record) }, status: :created
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.record.errors.full_messages.join(", ") }, status: :unprocessable_entity
  end

  def update
    @blockable_set.update!(blockable_set_params)
    render json: { language_chapter_blockable_set: serialize_set(@blockable_set.reload) }
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.record.errors.full_messages.join(", ") }, status: :unprocessable_entity
  end

  def destroy
    @blockable_set.destroy!
    head :no_content
  end

  private

  def set_language
    @language = Language.find(params[:language_id])
  end

  def set_blockable_set
    @blockable_set = LanguageChapterBlockableSet.find(params[:id])
  end

  def blockable_set_params
    params.require(:language_chapter_blockable_set).permit(:title, :description, :position, :example_payload)
  end

  def serialize_set(s)
    {
      id: s.id,
      language_id: s.language_id,
      title: s.title,
      description: s.description,
      position: s.position,
      example_payload: s.example_payload,
      language_chapter_blockable_options_count: s.language_chapter_blockable_options.size,
      prompt_rules: prompt_rules_json(s.language_chapter_blockable_prompt_rules)
    }
  end

  def prompt_rules_json(relation)
    relation.ordered.map { |r| { id: r.id, body: r.body, position: r.position } }
  end
end
