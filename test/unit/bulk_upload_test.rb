require 'test_helper'

class BulkUploadZipFileTest < ActiveSupport::TestCase
  test 'is invalid without a zip_file' do
    refute BulkUpload::ZipFile.new(nil).valid?
  end

  test 'is invalid if the zip file doesn\'t superficially look like a zip file' do
    refute BulkUpload::ZipFile.new(not_a_zip_file).valid?
  end

  test 'is invalid if the zip file superficially looks like a zip file, but isn\'t' do
    refute BulkUpload::ZipFile.new(superficial_zip_file).valid?
  end

  test 'is valid if the zip file is zippy' do
    assert BulkUpload::ZipFile.new(a_zip_file).valid?
  end

  test 'extracted_files gets a list of files and their on disk locations' do
    zf = BulkUpload::ZipFile.new(a_zip_file)
    extracted = zf.extracted_files
    assert_equal 2, extracted.size
    assert extracted.include?(['two-pages.pdf', File.join(zf.temp_dir, 'extracted', 'two-pages.pdf').to_s])
    assert extracted.include?(['greenpaper.pdf', File.join(zf.temp_dir, 'extracted', 'greenpaper.pdf').to_s])
  end

  test 'extracted_files ignores OS X resource fork files' do
    zf = BulkUpload::ZipFile.new(zip_file_with_os_x_resource_fork)
    extracted = zf.extracted_files
    assert_equal 1, extracted.size
    assert extracted.include?(['greenpaper.pdf', File.join(zf.temp_dir, 'extracted', 'greenpaper.pdf').to_s])
  end

  def not_a_zip_file
    ActionDispatch::Http::UploadedFile.new(filename: 'greenpaper.pdf', tempfile: File.open(Rails.root.join('test','fixtures','greenpaper.pdf')))
  end

  def superficial_zip_file
    ActionDispatch::Http::UploadedFile.new(filename: 'greenpaper-not-a-zip.zip', tempfile: File.open(Rails.root.join('test','fixtures','greenpaper.pdf')))
  end

  def a_zip_file
    ActionDispatch::Http::UploadedFile.new(filename: 'two-pages-and-greenpaper.zip', tempfile: File.open(Rails.root.join('test','fixtures','two-pages-and-greenpaper.zip')))
  end

  def zip_file_with_os_x_resource_fork
    ActionDispatch::Http::UploadedFile.new(filename: 'greenpaper-with-osx-resource-fork.zip', tempfile: File.open(Rails.root.join('test', 'fixtures', 'greenpaper-with-osx-resource-fork.zip')))
  end
end

class BulkUploadZipFileToAttachmentsTest < ActiveSupport::TestCase
  setup do
    @zip_file = mock
    @zip_file.responds_like(BulkUpload::ZipFile.new(nil))
    @params = HashWithIndifferentAccess.new
  end

  test '#manipulate_params! is fine when the edition is not present' do
    @zip_file.stubs(:extracted_files).returns [
      ['greenpaper.pdf', Rails.root.join('test','fixtures','greenpaper.pdf').to_s],
      ['two-pages.pdf', Rails.root.join('test','fixtures','two-pages.pdf').to_s]
    ]
    zfta = BulkUpload::ZipFileToAttachments.new(@zip_file, nil, @params)
    assert_nothing_raised do
      zfta.manipulate_params!
    end
  end

  test '#manipulate_params! adds no edition_attachments_attributes to params when the zip file is empty' do
    @zip_file.stubs(:extracted_files).returns []
    zfta = BulkUpload::ZipFileToAttachments.new(@zip_file, mock, @params)
    zfta.manipulate_params!
    refute @params.has_key?('edition_attachments_attributes')
  end

  test '#manipulate_params! will remove any pre-existing edition_attachments_attributes params (even if zip is empty)' do
    @params['edition_attachments_attributes'] = 'woo'
    @zip_file.stubs(:extracted_files).returns []
    zfta = BulkUpload::ZipFileToAttachments.new(@zip_file, mock, @params)
    zfta.manipulate_params!
    refute @params.has_key?('edition_attachments_attributes')
  end

  test '#manipulate_params! will add a attachments_were_bulk_uploaded flag (even if zip is empty)' do
    @zip_file.stubs(:extracted_files).returns []
    zfta = BulkUpload::ZipFileToAttachments.new(@zip_file, mock, @params)
    zfta.manipulate_params!
    assert @params.has_key?('attachments_were_bulk_uploaded')
  end

  test '#new_attachments is all of the files if the edition is not present' do
    @zip_file.stubs(:extracted_files).returns [
      ['dave.pdf', Rails.root.join('dave.pdf').to_s],
      ['brian.txt', Rails.root.join('brian.txt').to_s]
    ]
    zfta = BulkUpload::ZipFileToAttachments.new(@zip_file, nil, @params)
    new_attachments = zfta.new_attachments
    assert_equal ['dave.pdf', 'brian.txt'], new_attachments.map {|f,l| f}
  end

  test '#new_attachments is all of the files if the supplied edition doesn\'t have any attachments' do
    @zip_file.stubs(:extracted_files).returns [
      ['dave.pdf', Rails.root.join('dave.pdf').to_s],
      ['brian.txt', Rails.root.join('brian.txt').to_s]
    ]
    edition = mock
    edition.stubs(:attachments).returns([])
    zfta = BulkUpload::ZipFileToAttachments.new(@zip_file, edition, @params)
    new_attachments = zfta.new_attachments
    assert_equal ['dave.pdf', 'brian.txt'], new_attachments.map {|f,l| f}
  end

  test '#new_attachments is only those files that don\'t match the filename of an existing attachment on the supplied edition' do
    @zip_file.stubs(:extracted_files).returns [
      ['dave.pdf', Rails.root.join('dave.pdf').to_s],
      ['brian.txt', Rails.root.join('brian.txt').to_s]
    ]
    edition = mock
    edition.stubs(:attachments).returns([build_attachment('brian.txt')])
    zfta = BulkUpload::ZipFileToAttachments.new(@zip_file, edition, @params)
    new_attachments = zfta.new_attachments
    assert_equal ['dave.pdf'], new_attachments.map {|f,l| f}
  end

  test '#new_attachments is empty if all the files match a filename of an existing attachment on the supplied edition' do
    @zip_file.stubs(:extracted_files).returns [
      ['dave.pdf', Rails.root.join('dave.pdf').to_s],
      ['brian.txt', Rails.root.join('brian.txt').to_s]
    ]
    edition = mock
    edition.stubs(:attachments).returns([
      build_attachment('brian.txt'),
      build_attachment('dave.pdf')
    ])
    zfta = BulkUpload::ZipFileToAttachments.new(@zip_file, edition, @params)
    assert zfta.new_attachments.empty?
  end

  test '#replacement_attachments is empty if the edition is not present' do
    @zip_file.stubs(:extracted_files).returns [
      ['dave.pdf', Rails.root.join('dave.pdf').to_s],
      ['brian.txt', Rails.root.join('brian.txt').to_s]
    ]
    zfta = BulkUpload::ZipFileToAttachments.new(@zip_file, nil, @params)
    assert zfta.replacement_attachments.empty?
  end

  test '#replacement_attachments is empty if the supplied edition doesn\'t have any attachments' do
    @zip_file.stubs(:extracted_files).returns [
      ['dave.pdf', Rails.root.join('dave.pdf').to_s],
      ['brian.txt', Rails.root.join('brian.txt').to_s]
    ]
    edition = mock
    edition.stubs(:edition_attachments).returns([])
    zfta = BulkUpload::ZipFileToAttachments.new(@zip_file, edition, @params)
    assert zfta.replacement_attachments.empty?
  end

  test '#replacement_attachments is only those files that match the filename of an existing attachment on the supplied edition' do
    @zip_file.stubs(:extracted_files).returns [
      ['dave.pdf', Rails.root.join('dave.pdf').to_s],
      ['brian.txt', Rails.root.join('brian.txt').to_s]
    ]
    edition = mock
    edition.stubs(:edition_attachments).returns([build_edition_attachment('brian.txt')])
    zfta = BulkUpload::ZipFileToAttachments.new(@zip_file, edition, @params)
    replacement_attachments = zfta.replacement_attachments
    assert_equal ['brian.txt'], replacement_attachments.map {|f,l,a| f}
  end

  test '#replacement_attachments collects the edition attachment instance along with the file details if there are matches' do
    @zip_file.stubs(:extracted_files).returns [
      ['dave.pdf', Rails.root.join('dave.pdf').to_s],
      ['brian.txt', Rails.root.join('brian.txt').to_s]
    ]
    edition = mock
    edition_attachment = build_edition_attachment('brian.txt')
    edition.stubs(:edition_attachments).returns([edition_attachment])
    zfta = BulkUpload::ZipFileToAttachments.new(@zip_file, edition, @params)
    replacement_attachments = zfta.replacement_attachments
    assert_equal [edition_attachment], replacement_attachments.map {|f,l,a| a}
  end

  test '#replacement_attachments will fetch only the first edition attachment instance if there happen to be multiple that match' do
    @zip_file.stubs(:extracted_files).returns [
      ['dave.pdf', Rails.root.join('dave.pdf').to_s]
    ]
    edition = mock
    edition_attachment_1 = build_edition_attachment('dave.pdf')
    edition_attachment_2 = build_edition_attachment('dave.pdf')
    edition.stubs(:edition_attachments).returns([edition_attachment_2, edition_attachment_1])
    zfta = BulkUpload::ZipFileToAttachments.new(@zip_file, edition, @params)
    replacement_attachments = zfta.replacement_attachments
    assert_equal [edition_attachment_2], replacement_attachments.map {|f,l,a| a}
  end

  test '#replacement_attachments is all the zip files if they all match a filename of an existing attachment on the supplied edition' do
    @zip_file.stubs(:extracted_files).returns [
      ['dave.pdf', Rails.root.join('dave.pdf').to_s],
      ['brian.txt', Rails.root.join('brian.txt').to_s]
    ]
    edition = mock
    edition.stubs(:edition_attachments).returns([
      build_edition_attachment('brian.txt'),
      build_edition_attachment('dave.pdf')
    ])
    zfta = BulkUpload::ZipFileToAttachments.new(@zip_file, edition, @params)
    replacement_attachments = zfta.replacement_attachments
    assert_equal ['dave.pdf', 'brian.txt'], replacement_attachments.map {|f,l,a| f}
  end

  test '#add_params_for_new_attachments converts each file in #new_attachments into edition_attachments_attributes entries to create new edition_attachments' do
    @zip_file.stubs(:extracted_files).returns [['greenpaper.pdf', Rails.root.join('test','fixtures','greenpaper.pdf').to_s]]
    edition = mock
    edition.stubs(:attachments).returns []
    zfta = BulkUpload::ZipFileToAttachments.new(@zip_file, edition, @params)
    zfta.add_params_for_new_attachments

    assert_equal 1, @params['edition_attachments_attributes'].size
    assert_equal ['attachment_attributes'], @params['edition_attachments_attributes'][0].keys.sort
    assert_equal ['attachment_data_attributes'], @params['edition_attachments_attributes'][0]['attachment_attributes'].keys.sort
    assert_equal ['file'], @params['edition_attachments_attributes'][0]['attachment_attributes']['attachment_data_attributes'].keys.sort
    assert_equal 'greenpaper.pdf', @params['edition_attachments_attributes'][0]['attachment_attributes']['attachment_data_attributes']['file'].original_filename
    assert_equal Rails.root.join('test', 'fixtures', 'greenpaper.pdf').to_s, @params['edition_attachments_attributes'][0]['attachment_attributes']['attachment_data_attributes']['file'].tempfile.path
  end

  test '#add_params_to_replace_existing_attachments converts each file in #replacement_attachments into edition_attachments_attributes entries to update existing edition_attachments and replace their attachment_data' do
    @zip_file.stubs(:extracted_files).returns [['greenpaper.pdf', Rails.root.join('test','fixtures','greenpaper.pdf').to_s]]
    edition = mock
    edition.stubs(:edition_attachments).returns [
      build_edition_attachment('greenpaper.pdf', 10, 20, 30)
    ]
    zfta = BulkUpload::ZipFileToAttachments.new(@zip_file, edition, @params)
    zfta.add_params_to_replace_existing_attachments

    edition_attachments = @params['edition_attachments_attributes']
    assert_equal 1, edition_attachments.size
    assert_equal ['attachment_attributes', 'id'], edition_attachments[0].keys.sort
    assert_equal '10', @params['edition_attachments_attributes'][0]['id']
    assert_equal ['attachment_data_attributes', 'id'], edition_attachments[0]['attachment_attributes'].keys.sort
    assert_equal '20', @params['edition_attachments_attributes'][0]['attachment_attributes']['id']
    assert_equal ['file', 'to_replace_id'], edition_attachments[0]['attachment_attributes']['attachment_data_attributes'].keys.sort
    assert_equal '30', edition_attachments[0]['attachment_attributes']['attachment_data_attributes']['to_replace_id']
    assert_equal 'greenpaper.pdf', edition_attachments[0]['attachment_attributes']['attachment_data_attributes']['file'].original_filename
    assert_equal Rails.root.join('test', 'fixtures', 'greenpaper.pdf').to_s, edition_attachments[0]['attachment_attributes']['attachment_data_attributes']['file'].tempfile.path
  end

  def build_edition_attachment(for_file, id = 1, attachment_id = 2, attachment_data_id = 3)
    Struct.new(:attachment, :id).new(build_attachment(for_file, attachment_id, attachment_data_id), id)
  end
  def build_attachment(for_file, id = 1, attachment_data_id = 2)
    Struct.new(:filename, :id, :attachment_data_id).new(for_file, id, attachment_data_id)
  end
end
