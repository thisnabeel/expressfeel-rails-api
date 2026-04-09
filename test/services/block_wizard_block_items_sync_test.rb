# frozen_string_literal: true

# Standalone Minitest (not ActiveSupport::TestCase) so global `fixtures :all` in test_helper
# does not load YAML for tables missing from db/schema.rb.
require_relative "../../config/environment"
require "minitest/autorun"

class BlockWizardBlockItemsSyncTest < Minitest::Test
  def test_replace_layer_strip_creates_one_physical_block_per_tile_and_virtual_api_matches
    ActiveRecord::Base.transaction(requires_new: true) do
      lang = Language.create!(title: "block-sync-test-lang")
      chapter = Chapter.create!(title: "Block sync chapter", language: lang, position: 1)
      layer = ChapterLayer.create!(chapter: chapter, title: "Layer", position: 1)
      item = ChapterLayerItem.create!(chapter_layer: layer, body: "body", style: "inline", position: 1)
      set = LanguageChapterBlockableSet.create!(language: lang, title: "Set", position: 1)
      LanguageChapterBlockableOption.create!(
        language_chapter_blockable_set: set,
        title: "word",
        position: 0,
        display: "display"
      )
      LanguageChapterBlockableOption.create!(
        language_chapter_blockable_set: set,
        title: "translation",
        position: 1,
        display: "sub"
      )

      incoming = {
        "items" => [
          { "word" => "你好", "translation" => "hello" },
          { "word" => "谢谢", "translation" => "thanks" }
        ],
        "display_keys" => { "primary" => "word", "sub" => "translation" }
      }

      BlockWizardBlockItemsSync.replace_layer_strip!(item, set, incoming)
      item.reload

      phys = item.chapter_layer_item_blocks.where(blockable: set).order(:position, :id).to_a
      assert_equal 2, phys.size
      assert_equal 2, phys.first.chapter_layer_item_block_fields.count
      assert_equal 2, phys.last.chapter_layer_item_block_fields.count

      strips = ChapterBlockableStripJson.layer_item_strips(item)
      assert_equal 1, strips.size
      virt = strips.first
      assert_equal incoming["items"], virt[:details]["items"]
      assert_equal incoming["display_keys"], virt[:details]["display_keys"]

      row = ChapterBlockableStripJson.row_hash_for_physical_block(phys.last)
      assert_equal "thanks", row["translation"]

      raise ActiveRecord::Rollback
    end
  end
end
