require 'test_helper'

class AttachmentUploaderTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  test 'uses the asset manager and quarantined file storage engine' do
    assert_equal Whitehall::AssetManagerAndQuarantinedFileStorage, AttachmentUploader.storage
  end

  test 'indicates that assets are protected' do
    assert AttachmentUploader.new.assets_protected?
  end

  test 'should allow whitelisted file extensions' do
    graphics = %w(dxf eps gif jpg png ps)
    documents = %w(chm diff doc docx ics odp odt pdf ppt pptx rdf rtf txt)
    document_support = %w(ris)
    spreadsheets = %w(csv ods xls xlsm xlsx)
    markup = %w(gml kml sch wsdl xml xsd)
    containers = %w(zip)
    templates = %w(dot xlt xslt)

    allowed_attachments = graphics + documents + document_support + spreadsheets + markup + containers + templates
    assert_equal allowed_attachments.sort, AttachmentUploader.new.extension_whitelist.sort
  end

  test 'non-whitelisted file extensions are rejected' do
    uploader = AttachmentUploader.new(AttachmentData.new(id: 1), "mounted-as")

    exception = assert_raise CarrierWave::IntegrityError do
      uploader.store!(fixture_file_upload('dodgy.exe'))
    end

    assert_match %r(You are not allowed to upload "exe" files), exception.message
  end

  test "should store uploads in a directory that persists across deploys" do
    uploader = AttachmentUploader.new(AttachmentData.new(id: 1), "mounted-as")
    assert_match %r[^system], uploader.store_dir
  end

  test "should not generate thumbnail versions of non pdf files" do
    AttachmentUploader.enable_processing = true

    uploader = AttachmentUploader.new(FactoryBot.create(:attachment_data), "mounted-as")
    uploader.store!(fixture_file_upload('minister-of-funk.960x640.jpg', 'image/jpg'))

    assert_nil uploader.thumbnail.path

    AttachmentUploader.enable_processing = false
  end

  test "should be able to attach a xsd file" do
    AttachmentUploader.enable_processing = true

    uploader = AttachmentUploader.new(FactoryBot.create(:attachment_data), "mounted-as")
    uploader.store!(fixture_file_upload("sample.xsd"))
    assert uploader.file.present?

    AttachmentUploader.enable_processing = false
  end

  test "should be able to attach a zip file" do
    uploader = AttachmentUploader.new(FactoryBot.create(:attachment_data), "mounted-as")
    uploader.store!(fixture_file_upload('sample_attachment.zip'))
    assert uploader.file.present?
  end

  test "zip file containing a non-whitelisted format should be rejected" do
    uploader = AttachmentUploader.new(AttachmentData.new(id: 1), "mounted-as")
    assert_raise CarrierWave::IntegrityError do
      uploader.store!(fixture_file_upload('sample_attachment_containing_exe.zip'))
    end
  end

  test "zip file containing SHOUTED whitelisted format files should not be rejected" do
    uploader = AttachmentUploader.new(FactoryBot.create(:attachment_data), "mounted-as")
    AttachmentUploader::ZipFile.any_instance.stubs(:filenames).returns(['README.TXT', 'ImportantDocument.PDF', 'dIRE-sTRAITS.jPG'])
    assert_nothing_raised do
      uploader.store!(fixture_file_upload('sample_attachment.zip'))
    end
    assert uploader.file.present?
  end

  test "zip file containing a zip file should be rejected" do
    uploader = AttachmentUploader.new(AttachmentData.new(id: 1), "mounted-as")
    assert_raise CarrierWave::IntegrityError do
      uploader.store!(fixture_file_upload('sample_attachment_containing_zip.zip'))
    end
  end

  test "zip file containing files with non-UTF-8 filenames should be rejected" do
    uploader = AttachmentUploader.new(AttachmentData.new(id: 1), "mounted-as")
    AttachmentUploader::ZipFile.any_instance.stubs(:filenames).raises(AttachmentUploader::ZipFile::NonUTF8ContentsError)
    assert_raise CarrierWave::IntegrityError do
      uploader.store!(fixture_file_upload('sample_attachment.zip'))
    end
  end

  test 'zip file that looks like a minimal ArcGIS file should be allowed' do
    uploader = AttachmentUploader.new(FactoryBot.create(:attachment_data), 'mounted-as')
    AttachmentUploader::ZipFile.any_instance.stubs(:filenames).returns(required_arcgis_file_list)
    assert_nothing_raised do
      uploader.store!(fixture_file_upload('sample_attachment.zip'))
    end
    assert uploader.file.present?
  end

  test 'zip file that looks like a comprehensive ArcGIS file should be allowed' do
    uploader = AttachmentUploader.new(FactoryBot.create(:attachment_data), 'mounted-as')
    AttachmentUploader::ZipFile.any_instance.stubs(:filenames).returns(comprehensive_arcgis_file_list)
    assert_nothing_raised do
      uploader.store!(fixture_file_upload('sample_attachment.zip'))
    end
    assert uploader.file.present?
  end

  test 'zip file that is missing all the required ArcGIS files is not allowed' do
    uploader = AttachmentUploader.new(AttachmentData.new(id: 1), 'mounted-as')
    AttachmentUploader::ZipFile.any_instance.stubs(:filenames).returns(broken_arcgis_file_list)
    assert_raise CarrierWave::IntegrityError do
      uploader.store!(fixture_file_upload('sample_attachment.zip'))
    end
  end

  test 'zip file that looks like an ArcGIS file, but has extra files in it is not allowed' do
    uploader = AttachmentUploader.new(AttachmentData.new(id: 1), 'mounted-as')
    AttachmentUploader::ZipFile.any_instance.stubs(:filenames).returns(comprehensive_arcgis_file_list + ['readme.txt', 'london.jpg', 'map-printout.pdf'])
    assert_raise CarrierWave::IntegrityError do
      uploader.store!(fixture_file_upload('sample_attachment.zip'))
    end
  end

  test 'zip file that looks like an ArcGIS file with multiple sets of shapes is allowed' do
    uploader = AttachmentUploader.new(FactoryBot.create(:attachment_data), 'mounted-as')
    AttachmentUploader::ZipFile.any_instance.stubs(:filenames).returns(multiple_shape_arcgis_file_list)
    assert_nothing_raised do
      uploader.store!(fixture_file_upload('sample_attachment.zip'))
    end
    assert uploader.file.present?
  end

  test 'zip file that looks like an ArcGIS file with multiple sets of shapes is not allowed if one set of shapes is incomplete' do
    uploader = AttachmentUploader.new(AttachmentData.new(id: 1), 'mounted-as')
    AttachmentUploader::ZipFile.any_instance.stubs(:filenames).returns(complete_and_broken_shape_arcgis_file_list)
    assert_raise CarrierWave::IntegrityError do
      uploader.store!(fixture_file_upload('sample_attachment.zip'))
    end
  end

  test 'returns Asset Manager version of path' do
    uploader = AttachmentUploader.new(FactoryBot.create(:attachment_data), 'mounted-as')
    uploader.store!(fixture_file_upload('simple.pdf'))
    expected_path = "/government/uploads/system/uploads/attachment_data/mounted-as/#{uploader.model.id}/simple.pdf"
    assert_equal expected_path, uploader.file.asset_manager_path
  end

  def required_arcgis_file_list
    %w(london.shp london.shx london.dbf)
  end

  def optional_argis_file_list
    %w(
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
    )
  end

  def comprehensive_arcgis_file_list
    required_arcgis_file_list + optional_argis_file_list
  end

  def broken_arcgis_file_list
    required_arcgis_file_list.shuffle[1..-1]
  end

  def multiple_shape_arcgis_file_list
    comprehensive_arcgis_file_list +
      comprehensive_arcgis_file_list.map { |f| f.gsub('london', 'paris') }
  end

  def complete_and_broken_shape_arcgis_file_list
    broken_arcgis_file_list +
      comprehensive_arcgis_file_list.map { |f| f.gsub('london', 'paris') }
  end
end

class AttachmentUploaderPDFTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  setup do
    AttachmentUploader.enable_processing = true
    @uploader = AttachmentUploader.new(AttachmentData.new, "mounted-as")
  end

  teardown do
    AttachmentUploader.enable_processing = false
  end

  test "should provide a thumbnail of the PDF" do
    assert_respond_to @uploader, :thumbnail
  end

  test "should store the thumbnail with the PNG extension" do
    @uploader.store!(fixture_file_upload('two-pages-with-content.pdf'))
    assert @uploader.thumbnail.path.ends_with?(".png"), "should be a png"
  end

  test "should store an actual PNG" do
    expect_thumbnail_sent_to_asset_manager_to_be_an_actual_png

    @uploader.store!(fixture_file_upload('two-pages-with-content.pdf'))
    AssetManagerCreateWhitehallAssetWorker.drain
  end

  test "should ensure the content type of the stored thumbnail is image/png" do
    @uploader.store!(fixture_file_upload('two-pages-with-content.pdf'))
    assert_equal "image/png", @uploader.thumbnail.file.content_type
  end

  test "should scale the thumbnail down proportionally to A4" do
    expect_thumbnail_sent_to_asset_manager_to_be_scaled_proportionally

    @uploader.store!(fixture_file_upload('two-pages-with-content.pdf'))
    AssetManagerCreateWhitehallAssetWorker.drain
  end

  test "should use a generic thumbnail if conversion fails" do
    @uploader.thumbnail.stubs(:pdf_thumbnail_command).returns("false")

    expect_fallback_thumbnail_to_be_uploaded_to_asset_manager

    @uploader.store!(fixture_file_upload('two-pages-with-content.pdf'))
    AssetManagerCreateWhitehallAssetWorker.drain
  end

  test "should use a generic thumbnail if conversion takes longer than 10 seconds to complete" do
    @uploader.thumbnail.stubs(:pdf_thumbnail_command).raises(Timeout::Error)

    expect_fallback_thumbnail_to_be_uploaded_to_asset_manager

    @uploader.store!(fixture_file_upload('two-pages-with-content.pdf'))
    AssetManagerCreateWhitehallAssetWorker.drain
  end

  def expect_fallback_thumbnail_to_be_uploaded_to_asset_manager
    Services.asset_manager.stubs(:create_whitehall_asset)
    Services.asset_manager.expects(:create_whitehall_asset).with do |value|
      if value[:file].path.ends_with?('.png')
        generic_thumbnail_path = File.expand_path("app/assets/images/pub-cover.png")
        assert_equal File.binread(generic_thumbnail_path),
                     File.binread(value[:file].path),
                     "Thumbnailing when PDF conversion fails should use default image."
      end
    end
  end

  def expect_thumbnail_sent_to_asset_manager_to_be_an_actual_png
    Services.asset_manager.stubs(:create_whitehall_asset)
    Services.asset_manager.expects(:create_whitehall_asset).with do |value|
      if value[:file].path.ends_with?('.png')
        type = `file -b --mime-type "#{value[:file].path}"`
        assert_equal "image/png", type.strip
      end
    end
  end

  def expect_thumbnail_sent_to_asset_manager_to_be_scaled_proportionally
    Services.asset_manager.stubs(:create_whitehall_asset)
    Services.asset_manager.expects(:create_whitehall_asset).with do |value|
      if value[:file].path.ends_with?('.png')
        identify_details = `identify "#{Rails.root.join("public", value[:file].path)}"`

        _path, _type, geometry, _rest = identify_details.split
        width, height = geometry.split("x")

        assert (width == "105" || height == "140"), "geometry should be proportional scaled, but was #{geometry}"
      end
    end
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
    zipfile = AttachmentUploader::ZipFile.new(Rails.root.join('test/fixtures/folders.zip'))

    assert_same_elements ['text.txt', 'text with spaces.txt', 'more-text.txt'],
      zipfile.filenames
  end
end
