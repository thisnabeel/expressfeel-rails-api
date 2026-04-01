require "net/http"
require "json"

class ChapterImagesController < ApplicationController
  include ApiAuthenticatable

  before_action :set_chapter, only: [:index, :create]
  before_action :set_chapter_image, only: [:proxy, :wizard_bubbles, :update, :destroy]
  before_action :authenticate_api_admin!, only: [:create, :wizard_bubbles, :update, :destroy]

  def index
    imgs = @chapter.chapter_images.includes(:chapter_image_overlays).order(:position, :id)
    render json: { chapter_images: serialized_images(imgs) }
  end

  def create
    file = params[:file]
    return render json: { error: "No file provided" }, status: :unprocessable_entity if file.blank?

    uploader = ImageUploaderService.new
    key = "chapters/#{@chapter.id}/images/#{SecureRandom.uuid}"
    image_url = uploader.upload_aws(key, file.tempfile)
    next_position = @chapter.chapter_images.maximum(:position).to_i + 1

    chapter_image = @chapter.chapter_images.create!(
      image_url: image_url,
      position: params[:position].presence&.to_i || next_position,
      original_filename: file.original_filename
    )

    render json: { chapter_image: serialize_image(chapter_image) }, status: :created
  end

  def proxy
    image_uri = URI.parse(@chapter_image.image_url)
    http = Net::HTTP.new(image_uri.host, image_uri.port)
    http.use_ssl = image_uri.scheme == "https"
    request = Net::HTTP::Get.new(image_uri.request_uri)
    response = http.request(request)

    unless response.is_a?(Net::HTTPSuccess)
      return render json: { error: "Could not fetch source image" }, status: :bad_gateway
    end

    send_data(
      response.body,
      type: response["content-type"].presence || "image/jpeg",
      disposition: "inline"
    )
  rescue StandardError => e
    render json: { error: "Image proxy failed: #{e.message}" }, status: :bad_gateway
  end

  # POST /chapter_images/:id/wizard_bubbles
  # Calls detector microservice and bulk-creates rounded-rect overlays.
  def wizard_bubbles
    confidence = params[:confidence].presence&.to_f || 0.25
    detector = detect_bubbles(@chapter_image.image_url, confidence: confidence)
    boxes = Array(detector["boxes"])
    return render json: { overlays: [], count: 0 } if boxes.empty?

    start_position = @chapter_image.chapter_image_overlays.maximum(:position).to_i
    created = []
    ChapterImageOverlay.transaction do
      boxes.each_with_index do |box, idx|
        created << @chapter_image.chapter_image_overlays.create!(
          overlay_type: "rounded-rect",
          shape: {
            x: pct(box["x_pct"]),
            y: pct(box["y_pct"]),
            width: pct(box["width_pct"]),
            height: pct(box["height_pct"])
          },
          label: (start_position + idx + 1).to_s,
          position: start_position + idx + 1,
          rotation: 0
        )
      end
    end

    render json: {
      count: created.length,
      overlays: created.sort_by { |o| [o.position || 0, o.id || 0] }.map { |o| serialize_overlay(o) }
    }
  rescue StandardError => e
    Rails.logger.error("[chapter_images_wizard_bubbles] image #{@chapter_image&.id}: #{e.class}: #{e.message}")
    render json: { error: "Could not auto-detect bubbles right now." }, status: :unprocessable_entity
  end

  def update
    @chapter_image.update!(chapter_image_params)
    render json: { chapter_image: serialize_image(@chapter_image) }
  end

  def destroy
    @chapter_image.destroy!
    head :no_content
  end

  private

  def set_chapter
    @chapter = Chapter.find(params[:chapter_id])
  end

  def set_chapter_image
    @chapter_image = ChapterImage.find(params[:id])
  end

  def chapter_image_params
    params.require(:chapter_image).permit(:position)
  end

  def detector_base_url
    ENV["BUBBLE_DETECTOR_BASE_URL"].presence || "https://manga-bubble-detector-py-production.up.railway.app"
  end

  def detect_bubbles(image_url, confidence:)
    uri = URI.parse("#{detector_base_url}/predict/url")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == "https"
    req = Net::HTTP::Post.new(uri.request_uri)
    req["Content-Type"] = "application/json"
    req.body = { image_url: image_url, confidence: confidence }.to_json
    res = http.request(req)
    raise "bubble detector failed (#{res.code})" unless res.is_a?(Net::HTTPSuccess)
    JSON.parse(res.body)
  end

  def pct(value)
    v = value.to_f
    [[v, 0.0].max, 100.0].min.round(2)
  end

  def serialized_images(images)
    images.map { |img| serialize_image(img) }
  end

  def serialize_image(img)
    count =
      if img.association(:chapter_image_overlays).loaded?
        img.chapter_image_overlays.size
      else
        img.chapter_image_overlays.count
      end
    {
      id: img.id,
      chapter_id: img.chapter_id,
      image_url: img.image_url,
      original_filename: img.original_filename,
      position: img.position,
      overlays_count: count
    }
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
