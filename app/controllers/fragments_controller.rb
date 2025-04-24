class FragmentsController < ApplicationController
  before_action :set_fragment, only: [:show, :update, :destroy]

  # GET /fragments
  # GET /fragments.json
  def index
    @fragments = Fragment.all
  end

  def build
    if params[:puzzle] == true
      render status: 200, json: LanguageAdjective.find(params[:language_adjective_id]).blocks_quiz(Fragment.find(params[:fragment_id]))
    else
      render status: 200, json: Fragment.find(params[:fragment_id]).build(params[:language_adjective_id])
    end
  end

  # GET /fragments/1
  # GET /fragments/1.json
  def show
    render json: Fragment.find(params[:id])
  end

  # GET /fragments/new
  def new
    @fragment = Fragment.new
  end

  # GET /fragments/1/edit
  def edit
    @language = Language.find(params[:id])
  end

  # POST /fragments
  # POST /fragments.json
  def create
    @fragment = Fragment.new(fragment_params)
  end

  # PATCH/PUT /fragments/1
  # PATCH/PUT /fragments/1.json
  def update
  end

  # DELETE /fragments/1
  # DELETE /fragments/1.json
  def destroy
    @fragment.destroy
  end
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_fragment
      @fragment = Fragment.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def fragment_params
      params.require(:fragment).permit!
    end
end
