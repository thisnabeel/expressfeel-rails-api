class ImageUploaderService
  def upload_aws(key, file)
    s3 = Aws::S3::Resource.new

    # Detect content type from file
    content_type = Marcel::MimeType.for(file)
    file_ext = Rack::Mime::MIME_TYPES.invert[content_type] || '.bin'

    key_with_ext = "#{key}#{file_ext}"
    obj = s3.bucket('expressfeel').object(key_with_ext)

    puts "Uploading file #{key_with_ext} (#{content_type})"
    obj.upload_file(file, acl: 'public-read', content_type: content_type)

    obj.public_url
  end
end
