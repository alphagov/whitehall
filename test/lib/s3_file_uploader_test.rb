require "test_helper"

class S3FileUploaderTest < ActiveSupport::TestCase
  setup do
    setup_fog_mock
  end

  teardown do
    Fog::Mock.reset
  end

  test "has the expected filename and content" do
    s3_file = S3FileUploader.save_file_to_s3("test_file_name.txt", "hello, world\n")
    assert_equal "test_file_name.txt", s3_file.key
    file = @directory.files.get("test_file_name.txt")
    assert_not_nil file
    assert_equal "hello, world\n", file.body
  end
end
