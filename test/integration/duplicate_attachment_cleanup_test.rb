require 'test_helper'
require 'fileutils'
require 'data_hygiene/duplicate_attachment_fixer'

class DuplicateAttachmentCleanupTest < ActiveSupport::TestCase

  test "duplicate files are replaced with a renamed copy of themselves" do
    attachable = create(:policy_group)
    attachments =[
      attachment_1 = build(:file_attachment, attachable: attachable, file: file_fixture('whitepaper.pdf')),
      attachment_2 = build(:file_attachment, attachable: attachable, file: file_fixture('whitepaper.pdf')),
      attachment_3 = build(:file_attachment, attachable: attachable, file: file_fixture('whitepaper.pdf')),
      attachment_4 = build(:file_attachment, attachable: attachable, file: file_fixture('greenpaper.pdf')),
      attachment_5 = build(:file_attachment, attachable: attachable, file: file_fixture('whitepaper-1.pdf')),
      attachment_6 = build(:file_attachment, attachable: attachable, file: file_fixture('greenpaper.pdf'))
    ]
    attachments.each { |attachment| attachment.save(validate: false) }
    VirusScanHelpers.simulate_virus_scan

    attachment_1_file_data = attachment_1.attachment_data
    attachment_2_file_data = attachment_2.attachment_data
    attachment_3_file_data = attachment_3.attachment_data
    attachment_4_file_data = attachment_4.attachment_data
    attachment_5_file_data = attachment_5.attachment_data
    attachment_6_file_data = attachment_6.attachment_data

    DataHygiene::DupFilenameAttachmentFixer.new(attachable).run!
    VirusScanHelpers.simulate_virus_scan

    # first attachment remains unchanged
    assert_equal attachment_1_file_data, attachment_1.reload.attachment_data

    # second attachment's attaxchment data is replaced even though it is has different case
    new_attachment_data = attachment_2.reload.attachment_data
    refute_equal attachment_2_file_data.reload, new_attachment_data
    assert_equal attachment_2_file_data.replaced_by, new_attachment_data
    assert_equal 'whitepaper-2.pdf', new_attachment_data.filename
    assert_file_content_identical attachment_2_file_data, new_attachment_data

    # third attachment's attachment data is replaced with a renamed file
    new_attachment_data = attachment_3.reload.attachment_data
    refute_equal attachment_3_file_data.reload, new_attachment_data
    assert_equal attachment_3_file_data.replaced_by, new_attachment_data
    assert_equal 'whitepaper-3.pdf', new_attachment_data.filename
    assert_file_content_identical attachment_3_file_data, new_attachment_data

    # fourth and fifth attachments remains unchanged
    assert_equal attachment_4_file_data, attachment_4.reload.attachment_data
    assert_equal attachment_5_file_data, attachment_5.reload.attachment_data

    # last attachment is replaced and renamed
    new_attachment_data = attachment_6.reload.attachment_data
    refute_equal attachment_6_file_data.reload, new_attachment_data
    assert_equal attachment_6_file_data.replaced_by, new_attachment_data
    assert_equal 'greenpaper-1.pdf', new_attachment_data.filename
    assert_file_content_identical attachment_6_file_data, new_attachment_data
  end
end
