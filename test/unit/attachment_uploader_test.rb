require 'test_helper'

class AttachmentUploaderTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  test 'should only allow PDF, CSV, RTF, PNG, JPG, DOC, DOCX, XLS, XLSX, PPT, PPTX attachments' do
    uploader = AttachmentUploader.new
    assert_equal %w(pdf csv rtf png jpg doc docx xls xlsx ppt pptx), uploader.extension_white_list
  end

  test "should store uploads in a directory that persists across deploys" do
    model = stub("AR Model", id: 1)
    uploader = AttachmentUploader.new(model, "mounted-as")
    assert_match /^system/, uploader.store_dir
  end

  test "should not generate thumbnail versions of non pdf files" do
    AttachmentUploader.enable_processing = true

    model = stub("AR Model", id: 1)
    uploader = AttachmentUploader.new(model, "mounted-as")
    uploader.store!(fixture_file_upload('portas-review.jpg'))

    assert_nil uploader.thumbnail.path

    AttachmentUploader.enable_processing = false
  end
end

class AttachmentUploaderPDFTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  setup do
    AttachmentUploader.enable_processing = true
    model = stub("AR Model", id: 1)
    @uploader = AttachmentUploader.new(model, "mounted-as")

    @uploader.store!(fixture_file_upload('two-pages-with-content.pdf'))
  end

  teardown do
    AttachmentUploader.enable_processing = false
  end

  test "should provide a thumbnail of the PDF" do
    assert_respond_to @uploader, :thumbnail
  end

  test "should store the thumbnail as a PNG" do
    assert @uploader.thumbnail.path.ends_with?(".png"), "should be a png"
  end

  test "should scale the thumbnail down proportionally to A4" do
    identify_details = `identify "#{Rails.root.join("public", @uploader.thumbnail.path)}"`
    path, type, geometry, rest = identify_details.split
    width, height = geometry.split("x")

    assert (width == "105" || height == "140"), "geometry should be proportional scaled, but was #{geometry}"
  end
end