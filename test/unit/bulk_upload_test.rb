require 'test_helper'

class BulkUploadTest < ActiveSupport::TestCase

  def fixture_file(filename)
    File.open(File.join(Rails.root, 'test', 'fixtures', filename))
  end

  def attachments_params(*pairs)
    {}.tap do |params|
      pairs.each_with_index do |pair, i|
        attachment, data = pair
        params[i.to_s] = attachment.merge(attachment_data_attributes: data)
      end
    end
  end

  # Parameters suitable for posting to #create for attachments with new filenames
  def new_attachments_params
    attachments_params(
      [{ title: 'Title 1' }, { file: fixture_file('whitepaper.pdf') }],
      [{ title: 'Title 2' }, { file: fixture_file('greenpaper.pdf') }]
    )
  end

  def invalid_new_attachments_params
    new_attachments_params.tap { |params| params['0'][:title] = '' }
  end

  test '.from_files builds Attachment instances for an array of file paths' do
    paths = %w(greenpaper.pdf whitepaper.pdf).map { |f| fixture_file(f).path }
    bulk_upload = BulkUpload.from_files(create(:news_article), paths)
    assert_equal 2, bulk_upload.attachments.size
    assert_equal 'greenpaper.pdf', bulk_upload.attachments[0].filename
    assert_equal 'whitepaper.pdf', bulk_upload.attachments[1].filename
  end

  test '.from_files loads attachments from the edition if filenames match' do
    edition = create(:news_article, :with_attachment)
    existing = edition.attachments.first
    paths = ['whitepaper.pdf', existing.filename].map { |name| fixture_file(name).path }
    bulk_upload = BulkUpload.from_files(edition, paths)
    assert bulk_upload.attachments.first.new_record?, 'Attachment should be new record'
    refute bulk_upload.attachments.last.new_record?, "Attachment shouldn't be new record"
  end

  test '.from_files always builds new AttachmentData instances' do
    edition = create(:news_article, :with_attachment)
    existing = edition.attachments.first
    paths = ['whitepaper.pdf', existing.filename].map { |name| fixture_file(name).path }
    bulk_upload = BulkUpload.from_files(edition, paths)
    assert bulk_upload.attachments.all? { |a| a.attachment_data.new_record? }
  end

  test '.from_files sets replaced_by on existing AttachmentData when file re-attached' do
    edition = create(:news_article, :with_attachment)
    existing = edition.attachments.first
    paths = ['whitepaper.pdf', existing.filename].map { |name| fixture_file(name).path }
    bulk_upload = BulkUpload.from_files(edition, paths)
    new_attachment_data = bulk_upload.attachments.last.attachment_data
    new_attachment_data.save!
    assert_equal new_attachment_data, existing.attachment_data.reload.replaced_by
  end

  test '#attachments_attributes builds new AttachmentData when file attached' do
    edition = create(:news_article, :with_attachment)
    existing = edition.attachments.first
    bulk_upload = BulkUpload.new(edition)
    bulk_upload.attachments_attributes = attachments_params(
      [{ id: existing.id, title: 'Title' }, {}]
    )
    attachment = bulk_upload.attachments.first
    assert attachment.attachment_data.new_record?, 'AttachmentData should be new record'
  end

  test '#attachments_attributes sets replaced_by on existing AttachmentData when file re-attached' do
    edition = create(:news_article, :with_attachment)
    existing = edition.attachments.first
    bulk_upload = BulkUpload.new(edition)
    params = attachments_params(
      [{ id: existing.id, title: 'Title' }, { file: fixture_file(existing.filename) }]
    )
    bulk_upload.attachments_attributes = params
    bulk_upload.save_attachments
    new_attachment_data = bulk_upload.attachments.first.attachment_data
    assert_equal new_attachment_data, existing.attachment_data.reload.replaced_by
  end

  test '#save_attachments saves attachments to the edition' do
    edition = create(:news_article)
    bulk_upload = BulkUpload.new(edition)
    bulk_upload.attachments_attributes = new_attachments_params
    assert_difference('edition.attachments.count', 2) do
      assert bulk_upload.save_attachments, 'should return true'
    end
  end

  test '#save_attachments updates existing attachments' do
    edition = create(:news_article, :with_attachment)
    existing = edition.attachments.first
    new_title = 'New title for existing attachment'
    bulk_upload = BulkUpload.new(edition)
    bulk_upload.attachments_attributes = attachments_params(
      [{ id: existing.id, title: new_title }, { file: fixture_file(existing.filename) }]
    )
    bulk_upload.save_attachments
    assert_equal 1, edition.attachments.length
    assert_equal new_title, edition.attachments.reload.first.title
  end

  test '#save_attachments does not save any attachments if one is invalid' do
    edition = create(:news_article)
    bulk_upload = BulkUpload.new(edition)
    bulk_upload.attachments_attributes = invalid_new_attachments_params
    assert_no_difference('edition.attachments.count') do
      refute bulk_upload.save_attachments, 'should return false'
    end
  end

  test '#save_attachments adds errors when attachments are invalid' do
    edition = create(:news_article)
    bulk_upload = BulkUpload.new(edition)
    bulk_upload.attachments_attributes = invalid_new_attachments_params
    bulk_upload.save_attachments
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
    zip_file = BulkUpload::ZipFile.new(a_zip_file)
    extracted = zip_file.extracted_file_paths
    assert_equal 2, extracted.size
    assert extracted.include?(File.join(zip_file.temp_dir, 'extracted', 'two-pages.pdf').to_s)
    assert extracted.include?(File.join(zip_file.temp_dir, 'extracted', 'greenpaper.pdf').to_s)
  end

  test 'cleanup_extracted_files deletes the files that were unzipped' do
    zip_file = BulkUpload::ZipFile.new(a_zip_file)
    extracted = zip_file.extracted_file_paths
    zip_file.cleanup_extracted_files
    assert extracted.none? { |path| File.exist?(path) }, 'files should be deleted'
    refute File.exist?(zip_file.temp_dir), 'temporary dir should be deleted'
  end

  test 'extracted_file_paths ignores OS X resource fork files' do
    zip_file = BulkUpload::ZipFile.new(zip_file_with_os_x_resource_fork)
    extracted = zip_file.extracted_file_paths
    assert_equal 1, extracted.size
    assert extracted.include?(File.join(zip_file.temp_dir, 'extracted', 'greenpaper.pdf').to_s)
  end

  def uploaded_file(fixture_filename)
    ActionDispatch::Http::UploadedFile.new(
      filename: fixture_filename,
      tempfile: File.open(Rails.root.join('test', 'fixtures', fixture_filename))
    )
  end

  def not_a_zip_file
    uploaded_file('greenpaper.pdf')
  end

  def superficial_zip_file
    ActionDispatch::Http::UploadedFile.new(
      filename: 'greenpaper-not-a-zip.zip',
      tempfile: File.open(Rails.root.join('test', 'fixtures', 'greenpaper.pdf'))
    )
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
