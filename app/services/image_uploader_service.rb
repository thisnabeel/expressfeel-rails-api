require "uri"
require "cgi"

class ImageUploaderService
  def bucket_name
    ENV["AWS_S3_BUCKET"].presence || (defined?(AWS_CONFIG) ? AWS_CONFIG["bucket"] : nil) || "expressfeel"
  end

  def upload_aws(key, file)
    s3 = Aws::S3::Resource.new

    # Detect content type from file
    content_type = Marcel::MimeType.for(file)
    file_ext = Rack::Mime::MIME_TYPES.invert[content_type] || '.bin'

    key_with_ext = "#{key}#{file_ext}"
    obj = s3.bucket(bucket_name).object(key_with_ext)

    puts "Uploading file #{key_with_ext} (#{content_type})"
    obj.upload_file(file, acl: 'public-read', content_type: content_type)

    obj.public_url
  end

  def delete_public_url(url)
    uri = URI.parse(url.to_s)
    key = uri.path.to_s.sub(%r{\A/}, "")
    return if key.blank?

    s3 = Aws::S3::Resource.new
    s3.bucket(bucket_name).object(CGI.unescape(key)).delete
  rescue StandardError => e
    Rails.logger.error("[image_uploader] delete failed for #{url}: #{e.class}: #{e.message}")
  end
end
