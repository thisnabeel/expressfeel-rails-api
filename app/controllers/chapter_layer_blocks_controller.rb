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
      @item.chapter_layer_item_blocks.destroy_all
      return render json: { chapter_layer_blocks: chapter_layer_blocks_json_for(@item.reload) }
    end

    set = LanguageChapterBlockableSet.find(set_id)
    chapter = @item.chapter_layer.chapter
    if set.language_id != chapter.language_id
      return render json: { error: "Blockable set belongs to a different language" }, status: :unprocessable_entity
    end

    incoming = extract_details_from_params
    if incoming.present?
      BlockWizardBlockItemsSync.replace_layer_strip!(@item, set, incoming)
    elsif @item.chapter_layer_item_blocks.where(
      blockable_type: BlockWizardBlockItemsSync::SET_TYPE,
      blockable_id: set.id
    ).none?
      pos = (@item.chapter_layer_item_blocks.maximum(:position) || 0) + 1
      @item.chapter_layer_item_blocks.create!(
        blockable: set,
        position: pos,
        details: {}
      )
    end

    render json: { chapter_layer_blocks: chapter_layer_blocks_json_for(@item.reload) }, status: :created
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Not found" }, status: :not_found
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.record.errors.full_messages.join(", ") }, status: :unprocessable_entity
  end

  private

  def chapter_layer_blocks_json_for(item)
    ChapterBlockableStripJson.layer_item_strips(item.reload)
  end

  def set_item
    @item = ChapterLayerItem.find(params[:chapter_layer_item_id])
  end

  def extract_details_from_params
    raw = params[:chapter_layer_block]
    return {} if raw.blank?

    permitted = raw.permit(details: {})
    d = permitted[:details]
    return {} if d.blank?

    # Strong params returns ActionController::Parameters here, not Hash — must convert
    # or `is_a?(Hash)` fails and we never persist edits from the client.
    deep = d.respond_to?(:to_unsafe_h) ? d.to_unsafe_h : d
    deep.is_a?(Hash) ? deep : {}
  end
end
