class S3FileUploader
  def self.save_file_to_s3(filename, csv)
    params = if ENV.key? "AWS_ACCESS_KEY_ID"
               { aws_access_key_id: ENV["AWS_ACCESS_KEY_ID"],
                 aws_secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"] }
             else
               { use_iam_profile: true }
             end
    params.merge!({
      region: ENV["AWS_REGION"],

    })
    connection = Fog::AWS::Storage.new(params)

    directory = connection.directories.get(ENV["AWS_S3_BUCKET_NAME"])

    directory.files.create( # rubocop:disable Rails/SaveBang
      key: filename,
      body: csv,
      public: true,
    )
  end
end
