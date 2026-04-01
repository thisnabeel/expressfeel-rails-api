class LanguageChapterSublayersController < ApplicationController
  include ApiAuthenticatable

  before_action :set_language, only: [:index, :create]
  before_action :set_sublayer, only: [:update, :destroy]
  before_action :authenticate_api_admin!

  def index
    sublayers = @language.language_chapter_sublayers.ordered.includes(:sub_layer_items)
    render json: {
      language_chapter_sublayers: sublayers.map { |s| serialize_sublayer(s) }
    }
  end

  def create
    next_pos = @language.language_chapter_sublayers.maximum(:position).to_i + 1
    sublayer = @language.language_chapter_sublayers.create!(
      sublayer_params.merge(position: next_pos)
    )
    render json: { language_chapter_sublayer: serialize_sublayer(sublayer) }, status: :created
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.record.errors.full_messages.join(", ") }, status: :unprocessable_entity
  end

  def update
    @sublayer.update!(sublayer_params)
    render json: { language_chapter_sublayer: serialize_sublayer(@sublayer.reload) }
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.record.errors.full_messages.join(", ") }, status: :unprocessable_entity
  end

  def destroy
    counts = sublayer_link_counts(@sublayer)
    if counts[:sub_layer_items_total].positive?
      return render json: {
        error: "This sublayer still has linked sub-layer items. Remove those links first, or delete them from the item side.",
        sub_layer_items_total: counts[:sub_layer_items_total],
        linked_chapter_layer_items: counts[:linked_chapter_layer_items],
        linked_chapter_image_overlays: counts[:linked_chapter_image_overlays]
      }, status: :unprocessable_entity
    end

    @sublayer.destroy!
    head :no_content
  end

  private

  def set_language
    @language = Language.find(params[:language_id])
  end

  def set_sublayer
    @sublayer = LanguageChapterSublayer.find(params[:id])
  end

  def sublayer_params
    params.require(:language_chapter_sublayer).permit(:title, :description, :position, :wizarding_instructions)
  end

  def sublayer_link_counts(sublayer)
    grouped = sublayer.sub_layer_items.group(:sublayer_itemable_type).count
    li = grouped["ChapterLayerItem"].to_i
    ov = grouped["ChapterImageOverlay"].to_i
    {
      sub_layer_items_total: li + ov,
      linked_chapter_layer_items: li,
      linked_chapter_image_overlays: ov
    }
  end

  def serialize_sublayer(s)
    if s.association(:sub_layer_items).loaded?
      items = s.sub_layer_items.to_a
      by = items.group_by(&:sublayer_itemable_type)
      c = {
        sub_layer_items_total: items.length,
        linked_chapter_layer_items: by["ChapterLayerItem"]&.length || 0,
        linked_chapter_image_overlays: by["ChapterImageOverlay"]&.length || 0
      }
    else
      c = sublayer_link_counts(s)
    end
    {
      id: s.id,
      language_id: s.language_id,
      title: s.title,
      description: s.description,
      wizarding_instructions: s.wizarding_instructions,
      position: s.position,
      sub_layer_items_total: c[:sub_layer_items_total],
      linked_chapter_layer_items: c[:linked_chapter_layer_items],
      linked_chapter_image_overlays: c[:linked_chapter_image_overlays]
    }
  end
end
