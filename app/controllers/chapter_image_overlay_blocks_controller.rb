class ChapterImageOverlayBlocksController < ApplicationController
  include ApiAuthenticatable

  before_action :authenticate_api_admin!
  before_action :set_overlay, only: [:create]

  # POST /chapter_image_overlays/:chapter_image_overlay_id/overlay_blocks
  # body: { language_chapter_blockable_set_id: Integer | null, chapter_layer_block: { details: {} optional } }
  def create
    set_id = params[:language_chapter_blockable_set_id].presence

    if set_id.blank?
      @overlay.chapter_image_overlay_item_blocks.destroy_all
      @overlay.reload
      return render json: { chapter_layer_blocks: overlay_blocks_json_for(@overlay) }
    end

    set = LanguageChapterBlockableSet.find(set_id)
    chapter = @overlay.chapter_image&.chapter
    if chapter.blank? || set.language_id != chapter.language_id
      return render json: { error: "Blockable set belongs to a different language" }, status: :unprocessable_entity
    end

    incoming = extract_details_from_params
    if incoming.present?
      BlockWizardBlockItemsSync.replace_overlay_strip!(@overlay, set, incoming)
    elsif @overlay.chapter_image_overlay_item_blocks.where(
      blockable_type: BlockWizardBlockItemsSync::SET_TYPE,
      blockable_id: set.id
    ).none?
      pos = (@overlay.chapter_image_overlay_item_blocks.maximum(:position) || 0) + 1
      @overlay.chapter_image_overlay_item_blocks.create!(
        blockable: set,
        position: pos,
        details: {}
      )
    end

    @overlay.reload
    render json: { chapter_layer_blocks: overlay_blocks_json_for(@overlay) }, status: :created
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Not found" }, status: :not_found
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.record.errors.full_messages.join(", ") }, status: :unprocessable_entity
  end

  private

  def overlay_blocks_json_for(overlay)
    ChapterBlockableStripJson.overlay_strips(overlay.reload)
  end

  def set_overlay
    @overlay = ChapterImageOverlay.find(params[:chapter_image_overlay_id])
  end

  def extract_details_from_params
    raw = params[:chapter_layer_block]
    return {} if raw.blank?

    permitted = raw.permit(details: {})
    d = permitted[:details]
    return {} if d.blank?

    deep = d.respond_to?(:to_unsafe_h) ? d.to_unsafe_h : d
    deep.is_a?(Hash) ? deep : {}
  end
end
