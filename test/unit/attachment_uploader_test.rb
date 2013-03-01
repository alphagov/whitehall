require 'test_helper'

class AttachmentUploaderTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  test 'should only allow PDF, CSV, RTF, PNG, JPG, DOC, DOCX, XLS, XLSX, PPT, PPTX, ZIP, RDF, TXT, KML, ODS, ODT attachments' do
    uploader = AttachmentUploader.new
    allowed = %w(pdf csv rtf png jpg doc docx xls xlsx ppt pptx zip rdf txt kml odt ods)
    assert_equal allowed.sort, uploader.extension_white_list.sort
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
    uploader.store!(fixture_file_upload('minister-of-funk.960x640.jpg'))

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

  test "should store the thumbnail with the PNG extension" do
    assert @uploader.thumbnail.path.ends_with?(".png"), "should be a png"
  end

  test "should store an actual PNG" do
    type = `file -b --mime-type "#{@uploader.thumbnail.path}"`
    assert_equal "image/png", type.strip
  end

  test "should ensure the content type of the stored thumbnail is image/png" do
    assert_equal "image/png", @uploader.thumbnail.file.content_type
  end

  test "should scale the thumbnail down proportionally to A4" do
    identify_details = `identify "#{Rails.root.join("public", @uploader.thumbnail.path)}"`
    path, type, geometry, rest = identify_details.split
    width, height = geometry.split("x")

    assert (width == "105" || height == "140"), "geometry should be proportional scaled, but was #{geometry}"
  end

  test "should use a generic thumbnail if conversion fails" do
    model = stub("AR Model", id: 1)
    @uploader = AttachmentUploader.new(model, "mounted-as")
    @uploader.thumbnail.stubs(:pdf_thumbnail_command).returns("false")

    @uploader.store!(fixture_file_upload('two-pages-with-content.pdf'))

    assert @uploader.thumbnail.path.ends_with?(".png"), "should be a png"
    generic_thumbnail_path = File.expand_path("app/assets/images/pub-cover.png")
    assert_equal File.binread(generic_thumbnail_path),
                 File.binread(@uploader.thumbnail.path),
                 "Thumbnailing when PDF conversion fails should use default image."
  end
end
