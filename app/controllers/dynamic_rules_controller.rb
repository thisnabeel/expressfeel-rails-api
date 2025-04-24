class DynamicRulesController < ApplicationController
  before_action :set_dynamic_rule, only: %i[ show edit update destroy ]

  # GET /dynamic_rules or /dynamic_rules.json
  def index
    @dynamic_rules = DynamicRule.all
  end

  # GET /dynamic_rules/1 or /dynamic_rules/1.json
  def show
  end

  # GET /dynamic_rules/new
  def new
    @dynamic_rule = DynamicRule.new
  end

  # GET /dynamic_rules/1/edit
  def edit
  end

  # POST /dynamic_rules or /dynamic_rules.json
  def create
    @dynamic_rule = DynamicRule.new(dynamic_rule_params)
    if @dynamic_rule.save
      render json: @dynamic_rule
    else
      render json: @dynamic_rule.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /dynamic_rules/1 or /dynamic_rules/1.json
  def update
    if @dynamic_rule.update(dynamic_rule_params)
      render json: @dynamic_rule
    else
      render json: @dynamic_rule.errors, status: :unprocessable_entity
    end
  end

  # DELETE /dynamic_rules/1 or /dynamic_rules/1.json
  def destroy
    @dynamic_rule.destroy
  end

  def reorder
    dynamic_rule_updates = params[:list].map do |l|
      {
        id: l["id"].to_i,
        position: l["position"].to_i,
        dynamic_rule_id: l["dynamic_rule_id"].to_i > 0 ? l["dynamic_rule_id"].to_i : nil
      }
    end

    DynamicRule.upsert_all(dynamic_rule_updates)

    render status: 200, json: {
      message: "Success!",
    }.to_json
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_dynamic_rule
      @dynamic_rule = DynamicRule.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def dynamic_rule_params
      params.require(:dynamic_rule).permit!
    end
end
