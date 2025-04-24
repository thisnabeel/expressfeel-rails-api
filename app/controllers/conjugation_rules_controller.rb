class ConjugationRulesController < ApplicationController
  before_action :set_conjugation_rule, only: [:update, :destroy]

  # GET /conjugation_rules
  # GET /conjugation_rules.json
  def index
    @conjugation_rules = ConjugationRule.all
  end

  # GET /conjugation_rules/1
  # GET /conjugation_rules/1.json
  def show
    render json: Language.find(params[:id]).conjugation_rules
  end


  # POST /conjugation_rules
  # POST /conjugation_rules.json
  def create
    @conjugation_rule = ConjugationRule.new(conjugation_rule_params)
  end

  # PATCH/PUT /conjugation_rules/1
  # PATCH/PUT /conjugation_rules/1.json
  def update
  end

  # DELETE /conjugation_rules/1
  # DELETE /conjugation_rules/1.json
  def destroy
    @conjugation_rule.destroy
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_conjugation_rule
      @conjugation_rule = ConjugationRule.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def conjugation_rule_params
      params.require(:conjugation_rule).permit(:title, :description, :position, :trait_id, :slug, :required, :rules, :language_id)
    end
end
