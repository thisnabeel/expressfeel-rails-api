class ChapterLayersController < ApplicationController
  include ApiAuthenticatable

  before_action :authenticate_api_admin!
  before_action :set_chapter, only: [:create]
  before_action :set_layer, only: [:update, :destroy]

  def create
    @layer = @chapter.chapter_layers.new(layer_params)
    if @layer.save
      render json: @layer.as_json_for_viewer(admin: true), status: :created
    else
      render json: @layer.errors, status: :unprocessable_entity
    end
  end

  def update
    if @layer.update(layer_params)
      render json: @layer.as_json_for_viewer(admin: true)
    else
      render json: @layer.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @layer.destroy!
    head :no_content
  end

  private

  def set_chapter
    @chapter = Chapter.find(params[:chapter_id])
  end

  def set_layer
    @layer = ChapterLayer.find(params[:id])
  end

  def layer_params
    params.require(:chapter_layer).permit(:title, :active, :is_default, :position)
  end
end
