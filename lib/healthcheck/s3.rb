module Healthcheck
  class S3
    def name
      :s3
    end

    def status
      connection = S3FileHandler.connection
      connection.directories.get(ENV["AWS_S3_BUCKET_NAME"])

      GovukHealthcheck::OK
    rescue StandardError
      GovukHealthcheck::CRITICAL
    end
  end
end
