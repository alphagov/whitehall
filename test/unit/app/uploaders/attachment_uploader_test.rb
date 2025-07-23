require "test_helper"

class AttachmentUploaderTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  setup do
    edition = build(:draft_publication, id: 1)
    @attachment_data = build(:attachment_data, attachable: edition)
  end

  test "uses the attachment storage engine" do
    assert_equal Storage::AttachmentStorage, AttachmentUploader.storage
  end

  test "should allow whitelisted file extensions" do
    graphics = %w[dxf eps gif jpg png ps]
    documents = %w[chm diff doc docx ics odp odt pdf ppt pptx rdf rtf txt vcf]
    document_support = %w[ris]
    spreadsheets = %w[csv ods xls xlsm xlsx]
    markup = %w[gml kml sch wsdl xml xsd]
    templates = %w[dot xlt xslt]

    allowed_attachments = graphics + documents + document_support + spreadsheets + markup + templates
    assert_equal allowed_attachments.sort, AttachmentUploader.new(@attachment_data).extension_allowlist.sort
  end

  test "non-whitelisted file extensions are rejected" do
    uploader = AttachmentUploader.new(@attachment_data, "mounted-as")

    exception = assert_raise CarrierWave::IntegrityError do
      uploader.store!(file_fixture("dodgy.exe"))
    end

    assert_match %r{You are not allowed to upload "exe" files}, exception.message
  end

  test "should store uploads in a directory that persists across deploys" do
    uploader = AttachmentUploader.new(@attachment_data, "mounted-as")
    assert_match %r{^system}, uploader.store_dir
  end

  test "should be able to attach a xsd file" do
    AttachmentUploader.enable_processing = true

    uploader = AttachmentUploader.new(@attachment_data, "mounted-as")
    uploader.store!(file_fixture("sample.xsd"))
    assert uploader.file.present?

    AttachmentUploader.enable_processing = false
  end
end
