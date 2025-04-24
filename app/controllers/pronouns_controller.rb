class PronounsController < ApplicationController
  before_action :set_pronoun, only: [:show, :edit, :update, :destroy]

  # GET /pronouns
  # GET /pronouns.json
  def index
    @pronouns = Pronoun.all
    render json: @pronouns
  end

  # GET /pronouns/1
  # GET /pronouns/1.json
  def show
  end

  # GET /pronouns/new
  def new
    @pronoun = Pronoun.new
  end

  # GET /pronouns/1/edit
  def edit
  end

  # POST /pronouns
  # POST /pronouns.json
  def create
    @pronoun = Pronoun.new(pronoun_params)
    if @pronoun.save
      render json: @pronoun
    else
      render json: @pronoun.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /pronouns/1
  # PATCH/PUT /pronouns/1.json
  def update
    if @pronoun.update(pronoun_params)
      render json: @pronoun
    else
      render json: @pronoun.errors, status: :unprocessable_entity
    end
  end

  # DELETE /pronouns/1
  # DELETE /pronouns/1.json
  def destroy
    @pronoun.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_pronoun
      @pronoun = Pronoun.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def pronoun_params
      params.require(:pronoun).permit!
    end
end
