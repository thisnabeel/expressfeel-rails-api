aws_region = ENV["AWS_REGION"].presence || "us-east-1"

AWS_CONFIG = {
  'access_key_id' => ENV["AWS_ACCESS_KEY_ID"],
  'secret_access_key' => ENV["AWS_SECRET_ACCESS_KEY"],
  'bucket' => 'taqaddum',
  'region' => aws_region,
  'acl' => 'public-read',
  'key_start' => 'uploads/'
}

aws_cfg = { region: aws_region }
if ENV["AWS_ACCESS_KEY_ID"].present? && ENV["AWS_SECRET_ACCESS_KEY"].present?
  aws_cfg[:credentials] = Aws::Credentials.new(
    ENV["AWS_ACCESS_KEY_ID"],
    ENV["AWS_SECRET_ACCESS_KEY"]
  )
end
Aws.config.update(aws_cfg)

S3_BUCKET = Aws::S3::Resource.new.bucket('taqaddum')