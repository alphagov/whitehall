require 'test_helper'

class AttachmentUploaderTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  test 'should only allow PDF, CSV, RTF, PNG, JPG, DOC, DOCX, XLS, XLSX, PPT, PPTX, ZIP, RDF, TXT, KML attachments' do
    uploader = AttachmentUploader.new
    allowed = %w(pdf csv rtf png jpg doc docx xls xlsx ppt pptx zip rdf txt kml)
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

  test "should be able to attach a zip file" do
    uploader = AttachmentUploader.new(stub("AR Model", id: 1), "mounted-as")
    uploader.store!(fixture_file_upload('sample_attachment.zip'))
    assert uploader.file.present?
  end

  test "zip file containing a non-whitelisted format should be rejected" do
    uploader = AttachmentUploader.new(stub("AR Model", id: 1), "mounted-as")
    assert_raises CarrierWave::IntegrityError do
      uploader.store!(fixture_file_upload('sample_attachment_containing_exe.zip'))
    end
  end

  test "zip file containing a zip file should be rejected" do
    uploader = AttachmentUploader.new(stub("AR Model", id: 1), "mounted-as")
    assert_raises CarrierWave::IntegrityError do
      uploader.store!(fixture_file_upload('sample_attachment_containing_zip.zip'))
    end
  end

  test "zip file containing files with non-UTF-8 filenames should be rejected" do
    uploader = AttachmentUploader.new(stub("AR Model", id: 1), "mounted-as")
    AttachmentUploader::ZipFile.any_instance.stubs(:filenames).raises(AttachmentUploader::ZipFile::NonUTF8ContentsError)
    assert_raises CarrierWave::IntegrityError do
      uploader.store!(fixture_file_upload('sample_attachment.zip'))
    end
  end

  test 'zip file that looks like a minimal ArcGIS file should be allowed' do
    uploader = AttachmentUploader.new(stub("AR Model", id: 1), 'mounted-as')
    AttachmentUploader::ZipFile.any_instance.stubs(:filenames).returns(required_arcgis_file_list)
    assert_nothing_raised CarrierWave::IntegrityError do
      uploader.store!(fixture_file_upload('sample_attachment.zip'))
    end
    assert uploader.file.present?
  end

  test 'zip file that looks like a comprehensive ArcGIS file should be allowed' do
    uploader = AttachmentUploader.new(stub("AR Model", id: 1), 'mounted-as')
    AttachmentUploader::ZipFile.any_instance.stubs(:filenames).returns(comprehensive_arcgis_file_list)
    assert_nothing_raised CarrierWave::IntegrityError do
      uploader.store!(fixture_file_upload('sample_attachment.zip'))
    end
    assert uploader.file.present?
  end

  test 'zip file that is missing all the required ArcGIS files is not allowed' do
    uploader = AttachmentUploader.new(stub("AR Model", id: 1), 'mounted-as')
    AttachmentUploader::ZipFile.any_instance.stubs(:filenames).returns(broken_arcgis_file_list)
    assert_raises CarrierWave::IntegrityError do
      uploader.store!(fixture_file_upload('sample_attachment.zip'))
    end
  end

  test 'zip file that looks like an ArcGIS file, but has extra files in it is not allowed' do
    uploader = AttachmentUploader.new(stub("AR Model", id: 1), 'mounted-as')
    AttachmentUploader::ZipFile.any_instance.stubs(:filenames).returns(comprehensive_arcgis_file_list + ['readme.txt', 'london.jpg', 'map-printout.pdf'])
    assert_raises CarrierWave::IntegrityError do
      uploader.store!(fixture_file_upload('sample_attachment.zip'))
    end
  end

  test 'zip file that looks like an ArcGIS file, but has multiple copies of allowed files in it is not allowed' do
    uploader = AttachmentUploader.new(stub("AR Model", id: 1), 'mounted-as')
    AttachmentUploader::ZipFile.any_instance.stubs(:filenames).returns(duplicate_arcgis_file_list)
    assert_raises CarrierWave::IntegrityError do
      uploader.store!(fixture_file_upload('sample_attachment.zip'))
    end
  end

  def required_arcgis_file_list
    [
      'london.shp',
      'london.shx',
      'london.dbf'
    ]
  end

  def optional_argis_file_list
    [
      'london.prj',
      'london.sbn',
      'london.sbx',
      'london.fbn',
      'london.fbx',
      'london.ain',
      'london.aih',
      'london.ixs',
      'london.mxs',
      'london.atx',
      'london.shp.xml',
      'london.cpg'
    ]
  end

  def comprehensive_arcgis_file_list
    required_arcgis_file_list + optional_argis_file_list
  end

  def broken_arcgis_file_list
    required_arcgis_file_list.shuffle[1..-1]
  end

  def duplicate_arcgis_file_list
    comprehensive_arcgis_file_list +
      comprehensive_arcgis_file_list.map {|f| f.gsub('london', 'paris')}
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
