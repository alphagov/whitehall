require 'test_helper'


class BulkUploadTest < ActiveSupport::TestCase

  def fixture_file(filename)
    File.open(File.join(Rails.root, 'test', 'fixtures', filename))
  end

  def valid_attachments
    [ build(:attachment), build(:attachment) ]
  end

  def invalid_attachments
    [ build(:attachment, title: ''), build(:attachment) ]
  end

  test "can be instantiated from an array of file paths" do
    files = [ fixture_file('greenpaper.pdf'), fixture_file('whitepaper.pdf') ]

    attachments = BulkUpload.from_files(files)

    assert_equal 2, attachments.attachments.size
    assert_equal 'greenpaper.pdf', attachments.attachments[0].filename
    assert_equal 'whitepaper.pdf', attachments.attachments[1].filename
  end

  test '#save_attachments_to_edition saves attachments to the edition' do
    edition = create(:news_article)
    bulk_upload = BulkUpload.new
    bulk_upload.attachments = valid_attachments

    assert_difference('edition.attachments.count', 2) do
      assert bulk_upload.save_attachments_to_edition(edition), 'should return true'
    end
  end

  test '#save_attachments_to_edition does not save attachments if they are invalid' do
    edition = create(:news_article)
    bulk_upload = BulkUpload.new
    bulk_upload.attachments = invalid_attachments

    assert_no_difference('edition.attachments.count') do
      refute bulk_upload.save_attachments_to_edition(edition), 'should return false'
    end
  end

  test '#save_attachments_to_edition adds errors when attachments are invalid' do
    edition = create(:news_article)
    bulk_upload = BulkUpload.new
    bulk_upload.attachments = invalid_attachments
    bulk_upload.save_attachments_to_edition(edition)

    assert bulk_upload.errors[:base].any?
  end
end

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

  test 'is valid if the file is actually a zip' do
    assert BulkUpload::ZipFile.new(a_zip_file).valid?
  end

  test 'is invalid if the zip file contains illegal file types' do
    zip_file = BulkUpload::ZipFile.new(a_zip_file_with_dodgy_file_types)
    refute zip_file.valid?
    assert_match /contains invalid files/, zip_file.errors[:zip_file][0]
  end

  test 'extracted_file_paths returns extracted file paths' do
    zf = BulkUpload::ZipFile.new(a_zip_file)
    extracted = zf.extracted_file_paths
    assert_equal 2, extracted.size
    assert extracted.include?(File.join(zf.temp_dir, 'extracted', 'two-pages.pdf').to_s)
    assert extracted.include?(File.join(zf.temp_dir, 'extracted', 'greenpaper.pdf').to_s)
  end

  test 'extracted_file_paths ignores OS X resource fork files' do
    zf = BulkUpload::ZipFile.new(zip_file_with_os_x_resource_fork)
    extracted = zf.extracted_file_paths
    assert_equal 1, extracted.size
    assert extracted.include?(File.join(zf.temp_dir, 'extracted', 'greenpaper.pdf').to_s)
  end


  def uploaded_file(fixture_filename)
    ActionDispatch::Http::UploadedFile.new(filename: fixture_filename, tempfile: File.open(Rails.root.join('test', 'fixtures', fixture_filename)))
  end

  def not_a_zip_file
    uploaded_file('greenpaper.pdf')
  end

  def superficial_zip_file
    ActionDispatch::Http::UploadedFile.new(filename: 'greenpaper-not-a-zip.zip', tempfile: File.open(Rails.root.join('test','fixtures','greenpaper.pdf')))
  end

  def a_zip_file
    uploaded_file('two-pages-and-greenpaper.zip')
  end

  def zip_file_with_os_x_resource_fork
    uploaded_file('greenpaper-with-osx-resource-fork.zip')
  end

  def a_zip_file_with_dodgy_file_types
    uploaded_file('sample_attachment_containing_exe.zip')
  end
end
