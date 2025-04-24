class UserMissionsController < ApplicationController
  before_action :set_user_mission, only: [:show, :edit, :update, :destroy]

  # GET /user_missions
  # GET /user_missions.json
  def index
    @user_missions = UserMission.all
  end

  # GET /user_missions/1
  # GET /user_missions/1.json
  def show
  end

  # GET /user_missions/new
  def new
    @user_mission = UserMission.new
  end

  # GET /user_missions/1/edit
  def edit
  end

  # POST /user_missions
  # POST /user_missions.json
  def create
    @user_mission = UserMission.new(user_mission_params)
  end

  # PATCH/PUT /user_missions/1
  # PATCH/PUT /user_missions/1.json
  def update
  end

  # DELETE /user_missions/1
  # DELETE /user_missions/1.json
  def destroy
    @user_mission.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user_mission
      @user_mission = UserMission.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_mission_params
      params.require(:user_mission).permit(:user_id, :mission_id, :lesson_id, :language_id)
    end
end
