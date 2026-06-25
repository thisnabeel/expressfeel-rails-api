class LanguageConfigVariablesController < ApplicationController
  include ApiAuthenticatable

  before_action :set_language, only: [:index, :create]
  before_action :set_config_variable, only: [:update, :destroy, :move]
  before_action :authenticate_api_admin!, only: [:create, :update, :destroy, :move]

  def index
    render json: { config_variables: LanguageConfigVariable.tree_for_language(@language.id) }
  end

  def create
    @config_variable = @language.language_config_variables.new(config_variable_params)
    if @config_variable.save
      render json: serialize_node(@config_variable), status: :created
    else
      render json: { errors: @config_variable.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @config_variable.update(config_variable_params)
      render json: serialize_node(@config_variable.reload)
    else
      render json: { errors: @config_variable.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @config_variable.destroy!
    head :no_content
  end

  def move
    delta = params.require(:delta).to_i
    unless [-1, 1].include?(delta)
      return render json: { error: "delta must be -1 or 1" }, status: :unprocessable_entity
    end

    siblings = LanguageConfigVariable
      .where(language_id: @config_variable.language_id, config_variable_id: @config_variable.config_variable_id)
      .order(:position, :id)
      .to_a
    index = siblings.index(@config_variable)
    return head :unprocessable_entity unless index

    target_index = index + delta
    return head :unprocessable_entity if target_index.negative? || target_index >= siblings.length

    other = siblings[target_index]
    LanguageConfigVariable.transaction do
      position_one = @config_variable.position
      position_two = other.position
      @config_variable.update_columns(position: position_two)
      other.update_columns(position: position_one)
    end
    LanguageConfigVariable.renumber_siblings!(@config_variable.language_id, @config_variable.config_variable_id)
    head :ok
  end

  private

  def set_language
    @language = Language.find(params[:language_id])
  end

  def set_config_variable
    @config_variable = LanguageConfigVariable.find(params[:id])
  end

  def config_variable_params
    params.require(:config_variable).permit(:name, :value, :field_type, :config_variable_id, :position)
  end

  def serialize_node(row)
    {
      id: row.id,
      name: row.name,
      value: row.value,
      field_type: row.field_type,
      config_variable_id: row.config_variable_id,
      position: row.position,
      language_id: row.language_id
    }
  end
end
