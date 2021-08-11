module Healthcheck
  class S3
    def name
      :s3
    end

    def status
      if ENV["RUN_S3_HEALTHCHECK_FOR_WHITEHALL_BACKEND"].present?
        connection = S3FileHandler.connection
        connection.directories.get(ENV["AWS_S3_BUCKET_NAME"])
      end

      GovukHealthcheck::OK
    rescue StandardError
      GovukHealthcheck::CRITICAL
    end
  end
end
