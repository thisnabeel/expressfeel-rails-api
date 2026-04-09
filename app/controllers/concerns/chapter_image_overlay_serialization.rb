# Shared JSON for ChapterImageOverlay (index, create, update, wizard_bubbles).
module ChapterImageOverlaySerialization
  extend ActiveSupport::Concern

  def serialize_overlay(o)
    {
      id: o.id,
      chapter_image_id: o.chapter_image_id,
      overlay_type: o.overlay_type,
      shape: o.shape,
      label: o.label,
      original: o.original,
      translation: o.translation,
      position: o.position,
      rotation: o.rotation,
      sub_layer_items: sub_layer_items_json_for_overlay(o),
      chapter_layer_blocks: overlay_blocks_json_for_overlay(o)
    }
  end

  def sub_layer_items_json_for_overlay(o)
    items =
      if o.association(:sub_layer_items).loaded?
        o.sub_layer_items.sort_by { |s| [s.language_chapter_sublayer_id || 0, s.id || 0] }
      else
        o.sub_layer_items.includes(:language_chapter_sublayer).order(:language_chapter_sublayer_id, :id).to_a
      end
    items.map do |sli|
      {
        id: sli.id,
        language_chapter_sublayer_id: sli.language_chapter_sublayer_id,
        sublayer_name: sli.language_chapter_sublayer&.title,
        body: sli.body,
        hint: sli.hint
      }
    end
  end

  def overlay_blocks_json_for_overlay(o)
    if o.association(:chapter_image_overlay_item_blocks).loaded?
      blocks = o.chapter_image_overlay_item_blocks.sort_by { |b| [b.position || 0, b.id || 0] }
      ChapterBlockableStripJson.from_ordered_blocks(blocks)
    else
      ChapterBlockableStripJson.overlay_strips(o)
    end
  end
end
