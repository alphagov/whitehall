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
    containers = %w[zip]
    templates = %w[dot xlt xslt]

    allowed_attachments = graphics + documents + document_support + spreadsheets + markup + containers + templates
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

  test "should be able to attach a zip file" do
    uploader = AttachmentUploader.new(@attachment_data, "mounted-as")
    uploader.store!(file_fixture("sample_attachment.zip"))
    assert uploader.file.present?
  end

  test "zip file containing a non-whitelisted format should be rejected" do
    uploader = AttachmentUploader.new(@attachment_data, "mounted-as")
    assert_raise CarrierWave::IntegrityError do
      uploader.store!(file_fixture("sample_attachment_containing_exe.zip"))
    end
  end

  test "zip file containing SHOUTED whitelisted format files should not be rejected" do
    uploader = AttachmentUploader.new(@attachment_data, "mounted-as")
    AttachmentUploader::ZipFile.any_instance.stubs(:filenames).returns(["README.TXT", "ImportantDocument.PDF", "dIRE-sTRAITS.jPG"])
    assert_nothing_raised do
      uploader.store!(file_fixture("sample_attachment.zip"))
    end
    assert uploader.file.present?
  end

  test "zip file containing a zip file should be rejected" do
    uploader = AttachmentUploader.new(@attachment_data, "mounted-as")
    assert_raise CarrierWave::IntegrityError do
      uploader.store!(file_fixture("sample_attachment_containing_zip.zip"))
    end
  end

  test "zip file containing files with non-UTF-8 filenames should be rejected" do
    uploader = AttachmentUploader.new(@attachment_data, "mounted-as")
    AttachmentUploader::ZipFile.any_instance.stubs(:filenames).raises(AttachmentUploader::ZipFile::NonUTF8ContentsError)
    assert_raise CarrierWave::IntegrityError do
      uploader.store!(file_fixture("sample_attachment.zip"))
    end
  end

  test "zip file that looks like a minimal ArcGIS file should be allowed" do
    uploader = AttachmentUploader.new(@attachment_data, "mounted-as")
    AttachmentUploader::ZipFile.any_instance.stubs(:filenames).returns(required_arcgis_file_list)
    assert_nothing_raised do
      uploader.store!(file_fixture("sample_attachment.zip"))
    end
    assert uploader.file.present?
  end

  test "zip file that looks like a comprehensive ArcGIS file should be allowed" do
    uploader = AttachmentUploader.new(@attachment_data, "mounted-as")
    AttachmentUploader::ZipFile.any_instance.stubs(:filenames).returns(comprehensive_arcgis_file_list)
    assert_nothing_raised do
      uploader.store!(file_fixture("sample_attachment.zip"))
    end
    assert uploader.file.present?
  end

  test "zip file that is missing all the required ArcGIS files is not allowed" do
    uploader = AttachmentUploader.new(@attachment_data, "mounted-as")
    AttachmentUploader::ZipFile.any_instance.stubs(:filenames).returns(broken_arcgis_file_list)
    assert_raise CarrierWave::IntegrityError do
      uploader.store!(file_fixture("sample_attachment.zip"))
    end
  end

  test "zip file that looks like an ArcGIS file, but has extra files in it is not allowed" do
    uploader = AttachmentUploader.new(@attachment_data, "mounted-as")
    AttachmentUploader::ZipFile.any_instance.stubs(:filenames).returns(comprehensive_arcgis_file_list + ["readme.txt", "london.jpg", "map-printout.pdf"])
    assert_raise CarrierWave::IntegrityError do
      uploader.store!(file_fixture("sample_attachment.zip"))
    end
  end

  test "zip file that looks like an ArcGIS file with multiple sets of shapes is allowed" do
    uploader = AttachmentUploader.new(@attachment_data, "mounted-as")
    AttachmentUploader::ZipFile.any_instance.stubs(:filenames).returns(multiple_shape_arcgis_file_list)
    assert_nothing_raised do
      uploader.store!(file_fixture("sample_attachment.zip"))
    end
    assert uploader.file.present?
  end

  test "zip file that looks like an ArcGIS file with multiple sets of shapes is not allowed if one set of shapes is incomplete" do
    uploader = AttachmentUploader.new(@attachment_data, "mounted-as")
    AttachmentUploader::ZipFile.any_instance.stubs(:filenames).returns(complete_and_broken_shape_arcgis_file_list)
    assert_raise CarrierWave::IntegrityError do
      uploader.store!(file_fixture("sample_attachment.zip"))
    end
  end

  def required_arcgis_file_list
    %w[london.shp london.shx london.dbf]
  end

  def optional_argis_file_list
    %w[
      london.aih
      london.ain
      london.atx
      london.avl
      london.cpg
      london.fbn
      london.fbx
      london.ixs
      london.mxs
      london.prj
      london.sbn
      london.sbx
      london.shp.xml
      london.shp_rxl
    ]
  end

  def comprehensive_arcgis_file_list
    required_arcgis_file_list + optional_argis_file_list
  end

  def broken_arcgis_file_list
    required_arcgis_file_list.sample(2)
  end

  def multiple_shape_arcgis_file_list
    comprehensive_arcgis_file_list +
      comprehensive_arcgis_file_list.map { |f| f.gsub("london", "paris") }
  end

  def complete_and_broken_shape_arcgis_file_list
    broken_arcgis_file_list +
      comprehensive_arcgis_file_list.map { |f| f.gsub("london", "paris") }
  end
end

class AttachmentUploaderZipFileTest < ActiveSupport::TestCase
  test "#filenames returns the basename of all files, ignoring folders" do
    # folders.zip contains the following file structure:
    # folder/
    #  |-- text.txt
    #  |-- text with spaces.txt
    #  +-- another-folder/
    #       +-- more-text.txt
    #
    zipfile = AttachmentUploader::ZipFile.new(Rails.root.join("test/fixtures/folders.zip"))

    assert_same_elements ["text.txt", "text with spaces.txt", "more-text.txt"],
                         zipfile.filenames
  end
end
