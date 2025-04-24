class VideosController < ApplicationController
  before_action :set_video, only: [:show, :edit, :update, :destroy]

  # GET /videos
  # GET /videos.json
  def index
    @videos = Video.all
  end

  # GET /videos/1
  # GET /videos/1.json
  def show
  end

  # GET /videos/new
  def new
    @video = Video.new
  end

  # GET /videos/1/edit
  def edit
  end

  # POST /videos
  # POST /videos.json
  def create
    @video = Video.new(video_params)

  end

  # PATCH/PUT /videos/1
  # PATCH/PUT /videos/1.json
  def update

  end

  # DELETE /videos/1
  # DELETE /videos/1.json
  def destroy
    @video.destroy
    render json: { head: :no_content }
  end

  def search

    @videos = Video.where('unaccent(title) ILIKE ? OR unaccent(title) ILIKE ?', "%#{params[:search]}%", "%#{params[:search]}%")

    render json: @videos
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_video
      @video = Video.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def video_params
      params.require(:video).permit(:title, :url, :tags)
    end
end
