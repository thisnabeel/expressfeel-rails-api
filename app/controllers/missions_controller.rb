class MissionsController < ApplicationController
  before_action :set_mission, only: [:show, :edit, :update, :destroy, :present]

  # GET /missions
  # GET /missions.json
  def index
    @missions = Mission.all
  end

  # GET /missions/1
  # GET /missions/1.json
  def show
  end

  def present
    render layout: 'present'
  end

  # GET /missions/new
  def new
    @mission = Mission.new
  end

  # GET /missions/1/edit
  def edit
  end

  # POST /missions
  # POST /missions.json
  def create
    @mission = Mission.new(mission_params)
  end

  # PATCH/PUT /missions/1
  # PATCH/PUT /missions/1.json
  def update
  end

  # DELETE /missions/1
  # DELETE /missions/1.json
  def destroy
    @mission.destroy
  end

  def get_random
    @mission = Mission.where.not(video: [nil, ""]).sample
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_mission
      @mission = Mission.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def mission_params
      params.require(:mission).permit(:phrase_id, :body, :video)
    end
end
