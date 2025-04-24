class NounRulesController < ApplicationController
  before_action :set_noun_rule, only: [:show, :update, :destroy]

  # GET /noun_rules
  # GET /noun_rules.json
  def index
    @noun_rules = NounRule.all
  end

  # GET /noun_rules/1
  # GET /noun_rules/1.json
  def show
    render json: Language.find(params[:id]).noun_rules
  end

  # GET /noun_rules/new
  def new
    @noun_rule = NounRule.new
  end

  # GET /noun_rules/1/edit
  def edit
    @language = Language.find(params[:id])
    end  end

  # POST /noun_rules
  # POST /noun_rules.json
  def create
    @noun_rule = NounRule.new(noun_rule_params)
  end

  # PATCH/PUT /noun_rules/1
  # PATCH/PUT /noun_rules/1.json
  def update
  end

  # DELETE /noun_rules/1
  # DELETE /noun_rules/1.json
  def destroy
    @noun_rule.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_noun_rule
      @noun_rule = NounRule.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def noun_rule_params
      params.require(:noun_rule).permit(:title, :description, :position, :trait_id, :slug, :required, :rules, :language_id)
    end
end
