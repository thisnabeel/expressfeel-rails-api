class ImageUploaderService
  def upload_aws(id, item_folder, key, file)
    s3 = Aws::S3::Resource.new
    file_name = key + ".jpeg"
    obj = s3.bucket('expressfeel').object("#{item_folder}/#{id}/images/#{key}/#{file_name}")
    puts "Uploading file #{file_name}"
    obj.upload_file(file, acl:'public-read')
    return obj.public_url
  end
end