require "test_helper"

class ResponseDocumentUploaderTest < ActiveSupport::TestCase
  test "should only allow RTF, CSV, Word, Excel, ODT, ODS, or PDF images" do
    uploader = ResponseDocumentUploader.new
    assert_same_elements %w[rtf csv doc docx xls xlsx pdf odt ods], uploader.extension_allowlist
  end

  test "should store uploads in a directory that persists across deploys" do
    model = stub("AR Model", id: 1)
    uploader = ResponseDocumentUploader.new(model, "mounted-as")
    assert_match %r{^system}, uploader.store_dir
  end

  test "uses the asset manager storage engine" do
    assert_equal Whitehall::AssetManagerStorage, ResponseDocumentUploader.storage
  end
end
