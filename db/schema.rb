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

ActiveRecord::Schema[7.1].define(version: 2026_01_17_101221) do
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

  create_table "key_phrases", id: :serial, force: :cascade do |t|
    t.integer "lesson_key"
    t.string "phrase"
    t.text "body"
    t.string "recording"
    t.text "tags"
    t.integer "position"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "language_adjectives", id: :serial, force: :cascade do |t|
    t.text "folder"
    t.integer "adjective_id"
    t.integer "language_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "language_nouns", id: :serial, force: :cascade do |t|
    t.text "folder"
    t.integer "noun_id"
    t.integer "language_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "language_traits", id: :serial, force: :cascade do |t|
    t.text "body"
    t.integer "universal_id"
    t.integer "language_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "trait_id"
    t.boolean "active", default: false
    t.text "crawler"
    t.index ["language_id"], name: "index_language_traits_on_language_id"
    t.index ["universal_id"], name: "index_language_traits_on_universal_id"
  end

  create_table "language_verbs", id: :serial, force: :cascade do |t|
    t.integer "language_id"
    t.integer "verb_id"
    t.text "folder"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "languages", id: :serial, force: :cascade do |t|
    t.string "title"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "direction", default: "ltr"
    t.string "flags", default: ""
  end

  create_table "lesson_keys", id: :serial, force: :cascade do |t|
    t.string "language"
    t.text "body"
    t.text "examples"
    t.text "folder"
    t.integer "lesson_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "language_id"
  end

  create_table "lesson_plans", id: :serial, force: :cascade do |t|
    t.string "title"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "language_id"
  end

  create_table "lessons", id: :serial, force: :cascade do |t|
    t.string "expression"
    t.integer "position"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.text "objective"
    t.string "category"
    t.integer "lesson_plan_id"
  end

  create_table "machines", id: :serial, force: :cascade do |t|
    t.string "title"
    t.text "position"
    t.integer "language_id"
    t.text "description"
    t.text "allowed_inputs"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "material_tag_options", force: :cascade do |t|
    t.bigint "language_id", null: false
    t.string "title"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["language_id"], name: "index_material_tag_options_on_language_id"
  end

  create_table "material_tags", force: :cascade do |t|
    t.bigint "material_tag_option_id", null: false
    t.bigint "factory_material_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["factory_material_id"], name: "index_material_tags_on_factory_material_id"
    t.index ["material_tag_option_id"], name: "index_material_tags_on_material_tag_option_id"
  end

  create_table "missions", id: :serial, force: :cascade do |t|
    t.integer "phrase_id"
    t.text "body"
    t.string "video"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "noun_rules", id: :serial, force: :cascade do |t|
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

  create_table "nouns", id: :serial, force: :cascade do |t|
    t.string "base"
    t.string "category"
    t.string "tags"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "proper", default: false
    t.integer "quantity", default: 1
  end

  create_table "passport_phrases", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "phrase_id"
    t.integer "lesson_id"
    t.integer "language_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "phrase_dynamics", force: :cascade do |t|
    t.bigint "factory_dynamic_id"
    t.bigint "phrase_id"
    t.integer "position"
    t.json "input_selections", default: {}
    t.string "variable_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["factory_dynamic_id"], name: "index_phrase_dynamics_on_factory_dynamic_id"
    t.index ["phrase_id"], name: "index_phrase_dynamics_on_phrase_id"
  end

  create_table "phrase_factories", force: :cascade do |t|
    t.bigint "phrase_id", null: false
    t.bigint "factory_id", null: false
    t.integer "position"
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["factory_id"], name: "index_phrase_factories_on_factory_id"
    t.index ["phrase_id"], name: "index_phrase_factories_on_phrase_id"
  end

  create_table "phrase_input_payloads", force: :cascade do |t|
    t.bigint "phrase_input_id", null: false
    t.integer "phrase_payload_id"
    t.integer "factory_dynamic_input_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "payloadable_type"
    t.integer "payloadable_id"
    t.index ["payloadable_type", "payloadable_id"], name: "idx_on_payloadable_type_payloadable_id_970fa25673"
    t.index ["phrase_input_id"], name: "index_phrase_input_payloads_on_phrase_input_id"
  end

  create_table "phrase_input_permits", force: :cascade do |t|
    t.bigint "phrase_input_id", null: false
    t.bigint "material_tag_option_id"
    t.boolean "permit"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "factory_material_id"
    t.index ["factory_material_id"], name: "index_phrase_input_permits_on_factory_material_id"
    t.index ["material_tag_option_id"], name: "index_phrase_input_permits_on_material_tag_option_id"
    t.index ["phrase_input_id"], name: "index_phrase_input_permits_on_phrase_input_id"
  end

  create_table "phrase_inputs", force: :cascade do |t|
    t.string "phrase_inputable_type"
    t.integer "phrase_inputable_id"
    t.string "code"
    t.integer "position"
    t.integer "phrase_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "phrase_inputs_permits", force: :cascade do |t|
    t.bigint "phrase_input_id", null: false
    t.bigint "material_tag_option_id", null: false
    t.boolean "permit"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["material_tag_option_id"], name: "index_phrase_inputs_permits_on_material_tag_option_id"
    t.index ["phrase_input_id"], name: "index_phrase_inputs_permits_on_phrase_input_id"
  end

  create_table "phrase_orderings", force: :cascade do |t|
    t.jsonb "line", default: []
    t.text "description"
    t.integer "position"
    t.bigint "phrase_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "category"
    t.index ["phrase_id"], name: "index_phrase_orderings_on_phrase_id"
  end

  create_table "phrase_word_banks", force: :cascade do |t|
    t.bigint "phrase_id", null: false
    t.jsonb "words", default: []
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["phrase_id"], name: "index_phrase_word_banks_on_phrase_id"
  end

  create_table "phrases", id: :serial, force: :cascade do |t|
    t.string "title"
    t.text "body", default: ""
    t.string "recording"
    t.string "tags", default: ""
    t.integer "position"
    t.integer "language_id"
    t.integer "lesson_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "translit", default: ""
    t.boolean "ready", default: false
    t.json "new_formula", default: {}, null: false
    t.jsonb "formula", default: {"roman"=>[], "english"=>[], "original"=>[]}, null: false
  end

  create_table "poems", id: :serial, force: :cascade do |t|
    t.string "title"
    t.text "body"
    t.integer "language_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "link"
  end

  create_table "possessions", id: :serial, force: :cascade do |t|
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

  create_table "prompts", id: :serial, force: :cascade do |t|
    t.string "title"
    t.text "body"
    t.integer "difficulty"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "pronouns", id: :serial, force: :cascade do |t|
    t.string "word"
    t.string "category"
    t.string "tags"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "possession"
    t.string "object_word"
    t.string "is_word"
    t.string "do_word"
    t.string "has_word"
    t.boolean "countable", default: false, null: false
  end

  create_table "quest_step_lesson_payloads", force: :cascade do |t|
    t.bigint "quest_step_lesson_id", null: false
    t.string "materialable_type"
    t.integer "materialable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["quest_step_lesson_id"], name: "index_quest_step_lesson_payloads_on_quest_step_lesson_id"
  end

  create_table "quest_step_lessons", force: :cascade do |t|
    t.bigint "lesson_id", null: false
    t.bigint "quest_step_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lesson_id"], name: "index_quest_step_lessons_on_lesson_id"
    t.index ["quest_step_id"], name: "index_quest_step_lessons_on_quest_step_id"
  end

  create_table "quest_steps", force: :cascade do |t|
    t.string "image_url"
    t.string "thumbnail_url"
    t.bigint "quest_id", null: false
    t.integer "position"
    t.text "body"
    t.integer "success_step_id"
    t.integer "failure_step_id"
    t.integer "quest_reward_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["quest_id"], name: "index_quest_steps_on_quest_id"
  end

  create_table "quests", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.integer "position"
    t.bigint "quest_id"
    t.string "image_url"
    t.integer "difficulty"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["quest_id"], name: "index_quests_on_quest_id"
  end

  create_table "reactions", id: :serial, force: :cascade do |t|
    t.integer "factory_id"
    t.integer "position"
    t.string "tags"
    t.text "original"
    t.text "roman"
    t.text "english"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.text "instructions"
    t.text "roman_instructions"
    t.integer "machine_id"
  end

  create_table "subscriptions", id: :serial, force: :cascade do |t|
    t.string "plan_id"
    t.integer "user_id"
    t.boolean "active", default: true
    t.datetime "current_period_ends_at", precision: nil
    t.string "stripe_id"
  end

  create_table "traits", id: :serial, force: :cascade do |t|
    t.string "title"
    t.text "body"
    t.text "summary"
    t.integer "universal_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "trait_id"
    t.integer "position"
    t.string "code"
    t.string "tags", default: ""
    t.index ["universal_id"], name: "index_traits_on_universal_id"
  end

  create_table "universals", id: :serial, force: :cascade do |t|
    t.string "title"
    t.text "body"
    t.text "summary"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "user_missions", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "mission_id"
    t.integer "lesson_id"
    t.integer "language_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "username"
    t.text "blocked", default: "[]"
    t.text "friends", default: "[]"
    t.text "requests", default: "{}"
    t.text "peers", default: "[]"
    t.string "stripe_id"
    t.text "followers", default: "[]"
    t.text "following", default: "[]"
    t.datetime "last_read_news", precision: nil
    t.string "fingerprint"
    t.integer "ink"
    t.string "provider", default: "email", null: false
    t.string "uid", default: "", null: false
    t.json "tokens", default: "[]"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "verbs", id: :serial, force: :cascade do |t|
    t.string "infinitive"
    t.string "category"
    t.string "past"
    t.string "present"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "videos", id: :serial, force: :cascade do |t|
    t.string "title"
    t.string "url"
    t.string "tags"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "word_block_phrases", force: :cascade do |t|
    t.bigint "word_block_id", null: false
    t.bigint "phrase_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["phrase_id"], name: "index_word_block_phrases_on_phrase_id"
    t.index ["word_block_id", "phrase_id"], name: "index_word_block_phrases_on_block_and_phrase", unique: true
    t.index ["word_block_id"], name: "index_word_block_phrases_on_word_block_id"
  end

  create_table "word_blocks", force: :cascade do |t|
    t.string "original", null: false
    t.string "roman"
    t.string "english"
    t.bigint "language_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["language_id"], name: "index_word_blocks_on_language_id"
    t.index ["original"], name: "index_word_blocks_on_original"
  end

  add_foreign_key "factory_dynamic_inputs", "factories"
  add_foreign_key "factory_dynamic_inputs", "factory_dynamics"
  add_foreign_key "factory_dynamic_outputs", "factory_dynamic_inputs"
  add_foreign_key "factory_material_details", "factory_materials"
  add_foreign_key "language_traits", "languages"
  add_foreign_key "language_traits", "universals"
  add_foreign_key "material_tag_options", "languages"
  add_foreign_key "material_tags", "factory_materials"
  add_foreign_key "material_tags", "material_tag_options"
  add_foreign_key "phrase_dynamics", "factory_dynamics"
  add_foreign_key "phrase_dynamics", "phrases"
  add_foreign_key "phrase_factories", "factories"
  add_foreign_key "phrase_factories", "phrases"
  add_foreign_key "phrase_input_payloads", "phrase_inputs"
  add_foreign_key "phrase_input_permits", "factory_materials"
  add_foreign_key "phrase_input_permits", "material_tag_options"
  add_foreign_key "phrase_input_permits", "phrase_inputs"
  add_foreign_key "phrase_inputs_permits", "material_tag_options"
  add_foreign_key "phrase_inputs_permits", "phrase_inputs"
  add_foreign_key "phrase_orderings", "phrases"
  add_foreign_key "phrase_word_banks", "phrases"
  add_foreign_key "quest_step_lesson_payloads", "quest_step_lessons"
  add_foreign_key "quest_step_lessons", "lessons"
  add_foreign_key "quest_step_lessons", "quest_steps"
  add_foreign_key "quest_steps", "quests"
  add_foreign_key "quests", "quests"
  add_foreign_key "traits", "universals"
  add_foreign_key "word_block_phrases", "phrases"
  add_foreign_key "word_block_phrases", "word_blocks"
  add_foreign_key "word_blocks", "languages"
end
