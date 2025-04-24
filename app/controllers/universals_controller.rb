class UniversalsController < ApplicationController
  before_action :set_universal, only: [:show, :edit, :update, :destroy]

  # GET /universals
  # GET /universals.json
  def index
    @universals = Universal.all
  end

  # GET /universals/1
  # GET /universals/1.json
  def show
  end

  # GET /universals/new
  def new
    @universal = Universal.new
  end

  # GET /universals/1/edit
  def edit
  end

  # POST /universals
  # POST /universals.json
  def create
    @universal = Universal.new(universal_params)
  end

  # PATCH/PUT /universals/1
  # PATCH/PUT /universals/1.json
  def update
  end

  # DELETE /universals/1
  # DELETE /universals/1.json
  def destroy
    @universal.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_universal
      @universal = Universal.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def universal_params
      params.require(:universal).permit(:title, :body, :summary)
    end
end
