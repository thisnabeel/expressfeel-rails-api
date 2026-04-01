class ChapterImageOverlaysController < ApplicationController
  include ApiAuthenticatable

  before_action :set_chapter_image, only: [:index, :create]
  before_action :set_overlay, only: [:update, :destroy]
  before_action :authenticate_api_admin!, only: [:create, :update, :destroy]

  def index
    overlays = @chapter_image.chapter_image_overlays.order(:position, :id)
    render json: { overlays: overlays.map { |o| serialize_overlay(o) } }
  end

  def create
    overlay = @chapter_image.chapter_image_overlays.create!(
      overlay_type: params.require(:overlay_type),
      shape: params.require(:shape),
      label: params[:label].presence,
      original: params[:original].to_s,
      translation: params[:translation].to_s,
      position: params[:position].presence&.to_i || next_position
    )
    render json: { overlay: serialize_overlay(overlay) }, status: :created
  end

  def update
    @overlay.update!(overlay_params)
    render json: { overlay: serialize_overlay(@overlay) }
  end

  def destroy
    @overlay.destroy!
    head :no_content
  end

  private

  def set_chapter_image
    @chapter_image = ChapterImage.find(params[:chapter_image_id])
  end

  def set_overlay
    @overlay = ChapterImageOverlay.find(params[:id])
  end

  def next_position
    @chapter_image.chapter_image_overlays.maximum(:position).to_i + 1
  end

  def overlay_params
    params.require(:overlay).permit(
      :label, :original, :translation, :position, :overlay_type, :rotation,
      shape: {}
    )
  end

  def serialize_overlay(o)
    {
      id: o.id,
      chapter_image_id: o.chapter_image_id,
      overlay_type: o.overlay_type,
      shape: o.shape,
      label: o.label,
      original: o.original,
      translation: o.translation,
      position: o.position,
      rotation: o.rotation
    }
  end
end
