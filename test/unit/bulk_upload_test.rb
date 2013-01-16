require 'test_helper'

class BulkUploadZipFileTest < ActiveSupport::TestCase
  setup do
    FileUtils.mkdir_p(Rails.root.join('test-bulk-upload-zip-files'))
    Dir.stubs(:mktmpdir).returns(Rails.root.join('test-bulk-upload-zip-files'))
    zip_limit = BulkUpload::ZipFile::FILE_LIMIT
  end

  teardown do
    FileUtils.rm_rf(Rails.root.join('test-bulk-upload-zip-files'))
  end

  test 'is invalid without a zip_file' do
    refute BulkUpload::ZipFile.new(nil).valid?
  end

  test 'is invalid if the zip file doesn\'t superficially look like a zip file' do
    refute BulkUpload::ZipFile.new(not_a_zip_file).valid?
  end

  test 'is invalid if the zip file superficially looks like a zip file, but isn\'t' do
    refute BulkUpload::ZipFile.new(superficial_zip_file).valid?
  end

  test 'is invalid if the zip file is too big' do
    with_bulk_upload_zip_limit( File.size(Rails.root.join('test', 'fixtures', 'two-pages-and-greenpaper.zip')) - 1 ) do
      refute BulkUpload::ZipFile.new(a_zip_file).valid?
    end
  end

  test 'is valid if the zip file is zippy and not too big' do
    with_bulk_upload_zip_limit(File.size(Rails.root.join('test', 'fixtures', 'two-pages-and-greenpaper.zip')) + 1 ) do
      assert BulkUpload::ZipFile.new(a_zip_file).valid?
    end
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

  def with_bulk_upload_zip_limit(new_size, &block)
    old_size = BulkUpload::ZipFile::FILE_LIMIT
    begin
      BulkUpload::ZipFile.__send__(:remove_const, :FILE_LIMIT)
      BulkUpload::ZipFile.const_set(:FILE_LIMIT, new_size)
      block.call
    ensure
      BulkUpload::ZipFile.__send__(:remove_const, :FILE_LIMIT)
      BulkUpload::ZipFile.const_set(:FILE_LIMIT, old_size)
    end
  end
end
