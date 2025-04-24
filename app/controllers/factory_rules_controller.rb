class FactoryRulesController < ApplicationController
  before_action :set_factory_rule, only: [:show, :edit, :update, :destroy]

  # GET /factory_rules
  # GET /factory_rules.json
  def index
    @factory_rules = FactoryRule.all
  end

  # GET /factory_rules/1
  # GET /factory_rules/1.json
  def show
  end

  # GET /factory_rules/new
  def new
    @factory_rule = FactoryRule.new
  end

  # GET /factory_rules/1/edit
  def edit
  end

  # POST /factory_rules
  # POST /factory_rules.json
  def create
    @factory_rule = FactoryRule.new(factory_rule_params)
    if @factory_rule.save
      render json: @factory_rule
    else
      render json: @factory_rule.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /factory_rules/1
  # PATCH/PUT /factory_rules/1.json
  def update
    if @factory_rule.update(factory_rule_params)
      render json: @factory_rule
    else
      render json: @factory_rule.errors, status: :unprocessable_entity
    end
  end

  def reorder
    updated_rules = []
    params[:payload].each_with_index do |rule, index|
      rule = FactoryRule.find(rule["id"])
      rule.update(position: index + 1)
      updated_rules << rule
    end

    render json: updated_rules
  end


  # DELETE /factory_rules/1
  # DELETE /factory_rules/1.json
  def destroy
    @factory_rule.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_factory_rule
      @factory_rule = FactoryRule.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def factory_rule_params
      params.require(:factory_rule).permit(:title, :description, :position, :trait_id, :slug, :required, :rules, :factory_id)
    end
end
