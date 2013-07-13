require 'test_helper'


class BulkUploadTest < ActiveSupport::TestCase
  test "can be instantiated from an array of file paths" do
    files = [ Rails.root.join('test','fixtures','greenpaper.pdf'), Rails.root.join('test','fixtures','whitepaper.pdf') ]

    attachments = BulkUpload.from_files(files)

    assert_equal 2, attachments.attachments.size
    assert_equal 'greenpaper.pdf', attachments.attachments[0].filename
    assert_equal 'whitepaper.pdf', attachments.attachments[1].filename
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

  test 'is valid if the zip file is zippy' do
    assert BulkUpload::ZipFile.new(a_zip_file).valid?
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
