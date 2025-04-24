class GameAttemptsController < ApplicationController
  before_action :set_game_attempt, only: [:show, :edit, :update, :destroy]

  # GET /game_attempts
  # GET /game_attempts.json
  def index
    if teacher_signed_in?
      if params[:user_id].present?
        user = User.find(params[:user_id])
        @game_attempts = user.game_attempts.all
        @header = "#{user.full_name}'s Attempts"
      else 
        @game_attempts = GameAttempt.all
        @header = "Recent Attempts"
      end
    else
      @game_attempts = current_user.game_attempts
      @header = "My Attempts"
    end
  end

  # GET /game_attempts/1
  # GET /game_attempts/1.json
  def show
    @game = @game_attempt.game
  end

  # GET /game_attempts/new
  def new
    @game_attempt = GameAttempt.new
  end

  # GET /game_attempts/1/edit
  def edit
  end

  # POST /game_attempts
  # POST /game_attempts.json
  def create
    @game_attempt = GameAttempt.new(game_attempt_params)
  end

  # PATCH/PUT /game_attempts/1
  # PATCH/PUT /game_attempts/1.json
  def update
  end

  # DELETE /game_attempts/1
  # DELETE /game_attempts/1.json
  def destroy
    @game_attempt.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_game_attempt
      @game_attempt = GameAttempt.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def game_attempt_params
      params.require(:game_attempt).permit!
    end
end
