require 'test_helper'
require 'data_hygiene/duplicate_attachment_fixer'

class DupFilenameAttachmentFixerTest < ActiveSupport::TestCase
  include DataHygiene

  setup do
    @attachable = create(:policy_group)
    @attachments = [
      @attachment_1 = build(:file_attachment, attachable: @attachable, file: file_fixture('whitepaper.pdf')),
      @attachment_2 = build(:file_attachment, attachable: @attachable, file: file_fixture('whitepaper.pdf')),
      @attachment_3 = build(:file_attachment, attachable: @attachable, file: file_fixture('whitepaper.pdf')),
      @attachment_4 = build(:file_attachment, attachable: @attachable, file: file_fixture('greenpaper.pdf')),
      @attachment_5 = build(:file_attachment, attachable: @attachable, file: file_fixture('whitepaper-1.pdf')),
      @attachment_6 = build(:file_attachment, attachable: @attachable, file: file_fixture('greenpaper.pdf'))
    ]
    @attachments.each { |attachment| attachment.save(validate: false) }
    VirusScanHelpers.simulate_virus_scan
  end

  test "DuplicateFilenameReplacer#conflicts returns any attachments that have the same filename" do
    assert_equal [@attachment_2, @attachment_3], file_replacer(@attachment_1, @attachments).conflicts
    assert_equal [@attachment_1, @attachment_3], file_replacer(@attachment_2, @attachments).conflicts
    assert_equal [@attachment_1, @attachment_2], file_replacer(@attachment_3, @attachments).conflicts
    assert_equal [@attachment_6],                file_replacer(@attachment_4, @attachments).conflicts
    assert_equal [],                             file_replacer(@attachment_5, @attachments).conflicts
    assert_equal [@attachment_4],                file_replacer(@attachment_6, @attachments).conflicts
  end

  test "DuplicateFilenameReplacer#replace_duplicates replaces the attachment data with a renamed version of the same file" do
    original_data = @attachment_6.attachment_data
    file_replacer(@attachment_4, @attachments).replace_duplicates
    VirusScanHelpers.simulate_virus_scan

    # original data is replaced by new attachment data
    assert_equal @attachment_6.reload.attachment_data, original_data.reload.replaced_by
    assert_equal 'greenpaper.pdf', original_data.filename
    assert_file_content_identical file_fixture('greenpaper.pdf'), original_data

    # new attachment data has a unqique filename
    assert_equal 'greenpaper-1.pdf', @attachment_6.filename
    assert_file_content_identical original_data, @attachment_6.attachment_data
  end

  test "DuplicateFilenameReplacer#replace_duplicates is case sensitive and skips any filenames that are already in use" do
    original_data = @attachment_1.attachment_data
    attach_2_data = @attachment_2.attachment_data
    attach_3_data = @attachment_3.attachment_data

    file_replacer(@attachment_1, @attachments).replace_duplicates
    VirusScanHelpers.simulate_virus_scan

    # original remains unchanged
    assert_equal original_data, @attachment_1.reload.attachment_data
    assert_equal 'whitepaper.pdf', original_data.reload.filename
    assert_file_content_identical file_fixture('whitepaper.pdf'), original_data

    # conflicting files are renamed and replaced
    assert_equal 'whitepaper-2.pdf', @attachment_2.reload.filename
    assert_equal 'whitepaper-3.pdf', @attachment_3.reload.filename
    assert_equal attach_2_data.reload.replaced_by, @attachment_2.attachment_data
    assert_equal attach_3_data.reload.replaced_by, @attachment_3.attachment_data
    assert_file_content_identical file_fixture('whitepaper.pdf'), @attachment_2.attachment_data
    assert_file_content_identical file_fixture('whitepaper.pdf'), @attachment_3.attachment_data

    # existing ones are unchanged
    assert_equal 'greenpaper.pdf',   @attachment_4.filename
    assert_equal 'whitepaper-1.pdf', @attachment_5.filename
    assert_equal 'greenpaper.pdf',   @attachment_6.filename
  end

private

  def file_replacer(attachment, attachments)
    DataHygiene::DupFilenameAttachmentFixer::DuplicateFilenameReplacer.new(attachment, attachments)
  end
end
