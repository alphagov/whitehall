module Healthcheck
  class S3
    def name
      :s3
    end

    def status
      if ENV["SKIP_S3_HEALTHCHECK_FOR_PUBLISHING_E2E_TESTS"].blank?
        connection = S3FileHandler.connection
        connection.directories.get(ENV["AWS_S3_BUCKET_NAME"])
      end

      GovukHealthcheck::OK
    rescue StandardError
      GovukHealthcheck::CRITICAL
    end
  end
end
