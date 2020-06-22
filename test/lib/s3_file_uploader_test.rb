require "test_helper"

class S3FileUploaderTest < ActiveSupport::TestCase
  setup do
    Fog.mock!
    ENV["AWS_REGION"] = "eu-west-1"
    ENV["AWS_ACCESS_KEY_ID"] = "test"
    ENV["AWS_SECRET_ACCESS_KEY"] = "test"
    ENV["AWS_S3_BUCKET_NAME"] = "test-bucket"

    # Create an S3 bucket so the code being tested can find it
    connection = Fog::Storage.new(
      provider: "AWS",
      region: ENV["AWS_REGION"],
      aws_access_key_id: ENV["AWS_ACCESS_KEY_ID"],
      aws_secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"],
    )
    @directory = connection.directories.get(ENV["AWS_S3_BUCKET_NAME"]) || connection.directories.create(key: ENV["AWS_S3_BUCKET_NAME"]) # rubocop:disable Rails/SaveBang
  end

  test "has the expected filename and content" do
    s3_file = S3FileUploader.save_file_to_s3("test_file_name.txt", "hello, world\n")
    assert_equal "test_file_name.txt", s3_file.key
    file = @directory.files.get("test_file_name.txt")
    assert_not_nil file
    assert_equal "hello, world\n", file.body
  end
end
