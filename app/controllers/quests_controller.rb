class QuestsController < ApplicationController
  before_action :set_quest, only: %i[ show update destroy ]

  # GET /quests
  # GET /quests.json
  def index
    @quests = Quest.all
    render json: @quests
  end

  # GET /quests/1
  # GET /quests/1.json
  def show
    render json: @quest
  end

  def popular
    render json: Quest.popular
  end

  def quest_generation_wizard
    prompt = 'act as a quest maker for a language learning platform. quests look like this:

      create_table "quest_steps", force: :cascade do |t|
        t.string "image_url"
        t.bigint "quest_id", null: false
        t.text "body"
        t.integer "success_step_id"
        t.integer "failure_step_id"
        t.integer "quest_reward_id"
      end

      create_table "quests", force: :cascade do |t|
        t.string "title"
        t.text "description"
        t.bigint "quest_id"
        t.string "image_url"
        t.integer "difficulty"
      end

    ----
    a step can have an expected phrase like: "ask..." or "express..." or "command..." or "request..." etc
    correctly answering will move to the next step
    ----
    now make a quest in this style: ['+params[:prompt]+'], intermediate level max 10 steps
    respond exactly like this one flattened array of steps: [{body: "", expected_expression: "", example_answer: ""}, ...]'

    render json: WizardService.ask(prompt)
  end

  # POST /quests
  # POST /quests.json
  def create
    @quest = Quest.new(quest_params)

    if @quest.save
      render json: @quest, status: :created
    else
      render json: @quest.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /quests/1
  # PATCH/PUT /quests/1.json
  def update
    if @quest.update(quest_params)
      render json: @quest, status: :ok, location: @quest
    else
      render json: @quest.errors, status: :unprocessable_entity
    end
  end

  # DELETE /quests/1
  # DELETE /quests/1.json
  def destroy
    @quest.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_quest
      @quest = Quest.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def quest_params
      params.require(:quest).permit(:title, :description, :position, :quest_id, :image_url, :difficulty)
    end
end
