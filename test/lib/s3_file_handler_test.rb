require "test_helper"

class S3FileHandlerTest < ActiveSupport::TestCase
  setup do
    setup_fog_mock
  end

  teardown do
    Fog::Mock.reset
  end

  test "upload creates the right content and filename" do
    s3_file = S3FileHandler.save_file_to_s3("test_file_name.txt", "hello, world\n")
    assert_equal "test_file_name.txt", s3_file.key
    file = @directory.files.get("test_file_name.txt")
    assert_not_nil file
    assert_equal "hello, world\n", file.body
  end

  test "download fetches the right content" do
    S3FileHandler.save_file_to_s3("test_file_name.txt", "hello, world\n")
    file = S3FileHandler.get_file_from_s3("test_file_name.txt")
    assert_equal "hello, world\n", file
  end

  test "downloading a nonexistent file returns nil" do
    file = S3FileHandler.get_file_from_s3("not_a_real_file.txt")
    assert_nil file
  end
end
