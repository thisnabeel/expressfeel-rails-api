# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2026_03_22_120000) do
  create_schema "_heroku"
  create_schema "heroku_ext"

  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_stat_statements"
  enable_extension "pg_trgm"
  enable_extension "plpgsql"
  enable_extension "unaccent"

  create_table "adjective_rules", id: :serial, force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.integer "position"
    t.integer "trait_id"
    t.string "slug"
    t.boolean "required"
    t.text "rules"
    t.integer "language_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "adjectives", id: :serial, force: :cascade do |t|
    t.string "word"
    t.string "category"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "articles", id: :serial, force: :cascade do |t|
    t.string "title"
    t.text "body"
    t.string "tags"
    t.string "cover"
    t.integer "user_id"
    t.boolean "visibility"
    t.string "slug"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "subject"
  end

  create_table "billing_customers", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "stripeid", null: false
    t.string "default_source"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["user_id"], name: "index_billing_customers_on_user_id"
  end

  create_table "billing_plans", id: :serial, force: :cascade do |t|
    t.integer "billing_product_id", null: false
    t.string "stripeid", null: false
    t.string "stripe_plan_name"
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["billing_product_id"], name: "index_billing_plans_on_billing_product_id"
  end

  create_table "billing_products", id: :serial, force: :cascade do |t|
    t.string "stripeid", null: false
    t.string "stripe_product_name", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "billing_subscriptions", id: :serial, force: :cascade do |t|
    t.integer "billing_plan_id", null: false
    t.integer "billing_customer_id", null: false
    t.string "stripeid", null: false
    t.string "status", null: false
    t.datetime "current_period_end", precision: nil
    t.datetime "cancel_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["billing_customer_id"], name: "index_billing_subscriptions_on_billing_customer_id"
    t.index ["billing_plan_id"], name: "index_billing_subscriptions_on_billing_plan_id"
  end

  create_table "bottle_feedbacks", id: :serial, force: :cascade do |t|
    t.text "body"
    t.integer "user_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "bottles", id: :serial, force: :cascade do |t|
    t.text "intent"
    t.text "translation"
    t.integer "user_id"
    t.integer "prompt_id"
    t.integer "language_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "chapter_layer_items", force: :cascade do |t|
    t.bigint "chapter_layer_id", null: false
    t.text "body"
    t.string "style", default: "inline", null: false
    t.text "hint"
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chapter_layer_id", "position"], name: "index_chapter_layer_items_on_chapter_layer_id_and_position"
    t.index ["chapter_layer_id"], name: "index_chapter_layer_items_on_chapter_layer_id"
  end

  create_table "chapter_layers", force: :cascade do |t|
    t.bigint "chapter_id", null: false
    t.string "title", default: "", null: false
    t.boolean "active", default: true, null: false
    t.boolean "is_default", default: false, null: false
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chapter_id", "position"], name: "index_chapter_layers_on_chapter_id_and_position"
    t.index ["chapter_id"], name: "index_chapter_layers_on_chapter_id"
  end

  create_table "chapters", force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.bigint "chapter_id"
    t.integer "position", default: 0, null: false
    t.bigint "language_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chapter_id"], name: "index_chapters_on_chapter_id"
    t.index ["language_id", "chapter_id", "position"], name: "index_chapters_on_language_id_and_chapter_id_and_position"
    t.index ["language_id"], name: "index_chapters_on_language_id"
  end

  create_table "conjugation_rules", id: :serial, force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.integer "position"
    t.integer "trait_id"
    t.string "slug"
    t.boolean "required"
    t.text "rules"
    t.integer "language_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "conjugations", id: :serial, force: :cascade do |t|
    t.integer "language_id"
    t.integer "position"
    t.string "tags"
    t.text "original"
    t.text "roman"
    t.text "english"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.text "instructions"
    t.text "roman_instructions"
  end

  create_table "dynamic_rules", force: :cascade do |t|
    t.integer "factory_dynamic_id"
    t.integer "dynamic_rule_id"
    t.boolean "conditional"
    t.boolean "action"
    t.string "left"
    t.string "middle"
    t.string "right"
    t.string "output"
    t.integer "position"
    t.string "title"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.json "if_statements", default: []
    t.json "then_statements", default: []
  end

  create_table "factories", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "materials_title"
    t.string "reactions_title"
    t.integer "position"
    t.integer "language_id"
    t.boolean "active", default: true
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "materialable_type"
  end

  create_table "factory_dynamic_inputs", force: :cascade do |t|
    t.string "slug"
    t.bigint "factory_id"
    t.integer "position"
    t.string "selected_rule"
    t.bigint "factory_dynamic_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["factory_dynamic_id"], name: "index_factory_dynamic_inputs_on_factory_dynamic_id"
    t.index ["factory_id"], name: "index_factory_dynamic_inputs_on_factory_id"
  end

  create_table "factory_dynamic_outputs", force: :cascade do |t|
    t.string "slug"
    t.bigint "factory_dynamic_input_id", null: false
    t.string "initial_input_key"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["factory_dynamic_input_id"], name: "index_factory_dynamic_outputs_on_factory_dynamic_input_id"
  end

  create_table "factory_dynamic_parameters", force: :cascade do |t|
    t.string "material_name"
    t.integer "factory_dynamic_id"
    t.integer "position"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "factory_dynamics", id: :serial, force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.text "original_instructions", default: "--- []\n"
    t.text "roman_instructions", default: "--- []\n"
    t.text "english_instructions", default: "--- []\n"
    t.integer "factory_id"
    t.string "tags"
    t.integer "position"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.json "output_variables", default: []
    t.json "accepted_inputs", default: []
    t.jsonb "flow_config"
  end

  create_table "factory_material_details", force: :cascade do |t|
    t.bigint "factory_material_id", null: false
    t.string "slug"
    t.string "value"
    t.boolean "active"
    t.string "category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["factory_material_id"], name: "index_factory_material_details_on_factory_material_id"
  end

  create_table "factory_materials", id: :serial, force: :cascade do |t|
    t.bigint "materialable_id"
    t.string "materialable_type"
    t.integer "factory_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.jsonb "folder", default: {}, null: false
  end

  create_table "factory_rules", id: :serial, force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.integer "position"
    t.integer "trait_id"
    t.string "slug"
    t.boolean "required"
    t.text "rules"
    t.integer "factory_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "fragments", id: :serial, force: :cascade do |t|
    t.integer "language_id"
    t.integer "position"
    t.string "tags"
    t.text "original"
    t.text "roman"
    t.text "english"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.text "instructions"
    t.text "roman_instructions"
  end

  create_table "game_attempts", id: :serial, force: :cascade do |t|
    t.integer "game_id"
    t.integer "user_id"
    t.text "body"
    t.integer "result"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "game_questions", id: :serial, force: :cascade do |t|
    t.text "question"
    t.text "choices"
    t.string "correct"
    t.integer "game_id"
    t.index ["game_id"], name: "index_game_questions_on_game_id"
  end

  create_table "games", id: :serial, force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.string "game_type"
    t.text "folder"
    t.integer "language_trait_id"
    t.integer "gameable_id"
    t.integer "gameable_type"
    t.integer "play_size", default: 10
    t.boolean "random", default: true
    t.integer "position"
    t.index ["language_trait_id"], name: "index_games_on_language_trait_id"
  end

  create_table "guides", id: :serial, force: :cascade do |t|
    t.string "title"
    t.text "body"
    t.string "source_url"
    t.string "slug"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "faq", default: true
    t.integer "position"
  end

