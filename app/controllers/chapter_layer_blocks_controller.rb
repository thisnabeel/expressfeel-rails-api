class ChapterLayerBlocksController < ApplicationController
  include ApiAuthenticatable

  before_action :authenticate_api_admin!
  before_action :set_item, only: [:create]

  # POST /chapter_layer_items/:chapter_layer_item_id/chapter_layer_blocks
  # body: { language_chapter_blockable_set_id: Integer | null, chapter_layer_block: { details: {} optional } }
  # Upserts one block for the given set; other sets' blocks on this item are unchanged. Blank id clears all blocks.
  def create
    set_id = params[:language_chapter_blockable_set_id].presence

    if set_id.blank?
      @item.chapter_layer_blocks.destroy_all
      return render json: { chapter_layer_blocks: chapter_layer_blocks_json_for(@item.reload) }
    end

    set = LanguageChapterBlockableSet.find(set_id)
    chapter = @item.chapter_layer.chapter
    if set.language_id != chapter.language_id
      return render json: { error: "Blockable set belongs to a different language" }, status: :unprocessable_entity
    end

    incoming = extract_details_from_params
    block = @item.chapter_layer_blocks.find_or_initialize_by(blockable: set)
    block.position = set.position || set.id
    if incoming.present?
      block.details = incoming
    elsif block.new_record?
      block.details = {}
    end
    block.save!

    render json: { chapter_layer_blocks: chapter_layer_blocks_json_for(@item.reload) }, status: :created
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Not found" }, status: :not_found
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.record.errors.full_messages.join(", ") }, status: :unprocessable_entity
  end

  private

  def chapter_layer_blocks_json_for(item)
    item.chapter_layer_blocks
      .includes(:blockable)
      .order(:position, :id)
      .map(&:as_json_for_chapter)
  end

  def set_item
    @item = ChapterLayerItem.find(params[:chapter_layer_item_id])
  end

  def extract_details_from_params
    raw = params[:chapter_layer_block]
    return {} if raw.blank?

    permitted = raw.permit(details: {})
    d = permitted[:details]
    d.is_a?(Hash) ? d : {}
  end
end
