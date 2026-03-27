require "net/http"

class ChapterImagesController < ApplicationController
  include ApiAuthenticatable

  before_action :set_chapter, only: [:index, :create]
  before_action :set_chapter_image, only: [:proxy, :update, :destroy]
  before_action :authenticate_api_admin!, only: [:create, :update, :destroy]

  def index
    render json: { chapter_images: serialized_images(@chapter.chapter_images.order(:position, :id)) }
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

  def serialized_images(images)
    images.map { |img| serialize_image(img) }
  end

  def serialize_image(img)
    {
      id: img.id,
      chapter_id: img.chapter_id,
      image_url: img.image_url,
      original_filename: img.original_filename,
      position: img.position
    }
  end
end
