class S3FileHandler
  def self.get_csv_file_from_s3(filename)
    directory = connection.directories.get(ENV["AWS_S3_BUCKET_NAME"])

    file = directory.files.get(filename)

    raise Fog::AWS::Storage::NotFound, "Object #{filename} does not exist." if file.nil?

    file.body
  end

  def self.save_file_to_s3(filename, csv)
    directory = connection.directories.get(ENV["AWS_S3_BUCKET_NAME"])

    directory.files.create( # rubocop:disable Rails/SaveBang
      key: filename,
      body: csv,
      public: true,
    )
  end

  def self.connection
    params = if ENV.key? "AWS_ACCESS_KEY_ID"
               { aws_access_key_id: ENV["AWS_ACCESS_KEY_ID"],
                 aws_secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"] }
             else
               { use_iam_profile: true }
             end
    params.merge!({
      region: ENV["AWS_REGION"],

    })
    @connection ||= Fog::AWS::Storage.new(params)
  end
end
