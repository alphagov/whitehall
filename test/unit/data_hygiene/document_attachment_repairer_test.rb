require 'test_helper'

module DataHygiene
  class DocumentAttachmentRepairerTest < ActiveSupport::TestCase

    # Published editions #####

    test 're-editions a published document with a new (renamed) attachment that replaces the previous one' do
      bad_attachment = create(:file_attachment, file: double_extension_file, title: 'attachment title')
      VirusScanHelpers.simulate_virus_scan

      edition = create( :publication, :published,
                        alternative_format_provider: create(:organisation_with_alternative_format_contact_email),
                        attachments: [bad_attachment] )
      document = edition.document
      repairer = repairer_for(document)

      assert_difference('document.editions.count') do
        repairer.repair_attachments!
      end

      new_edition = document.reload.latest_edition

      assert_not_equal edition, new_edition
      assert new_edition.published?, "new edition should be published, but is currently :#{new_edition.state}"
      assert new_edition.minor_change?
      assert_equal gds_team_user, new_edition.last_author
      assert_equal 'Re-editioned with corrected attachment filename(s)', new_edition.editorial_remarks.last.body

      assert attachment = new_edition.attachments(true).first
      assert_equal 'attachment title', attachment.title
      assert_equal 'whitepaper.pdf', attachment.filename

      attachment_data = attachment.attachment_data
      VirusScanHelpers.simulate_virus_scan

      assert_equal attachment_data, bad_attachment.attachment_data(true).replaced_by
      assert FileUtils.identical?(bad_attachment.file.path, attachment.file.path)
    end

    test 'repairs multiple attachments for published documents' do
      bad_attachment1 = create(:file_attachment, file: double_extension_file, title: 'attachment 1')
      bad_attachment2 = create(:file_attachment, file: double_extension_file, title: 'attachment 2')
      VirusScanHelpers.simulate_virus_scan

      edition = create( :publication, :published,
                        alternative_format_provider: create(:organisation_with_alternative_format_contact_email),
                        attachments: [bad_attachment1, bad_attachment2] )
      document = edition.document
      repairer = repairer_for(document)

      assert_difference('document.editions.count') do
        repairer.repair_attachments!
      end

      new_edition = document.reload.latest_edition

      assert new_edition.published?, "new edition should be published, but is currently :#{new_edition.state}"
      assert_equal 2, new_edition.attachments.size
      assert_equal 'attachment 1', new_edition.attachments[0].title
      assert_equal 'attachment 2', new_edition.attachments[1].title
      new_edition.attachments.each do |attachment|
        assert_equal 'whitepaper.pdf', attachment.filename
      end
    end

    test  'only replaces attachments that need replacing' do
      bad_attachment = create(:file_attachment, file: double_extension_file, title: 'attachment 1')
      good_attachment = create(:file_attachment, file: File.open(Rails.root.join('test', 'fixtures', 'greenpaper.pdf')),title: 'attachment 2')
      good_attachment_data = good_attachment.attachment_data
      replaced_attachment = create(:file_attachment, file: double_extension_file)
      replaced_attachment.attachment_data.replaced_by = create(:file_attachment).attachment_data
      replaced_attachment_data = replaced_attachment.attachment_data
      VirusScanHelpers.simulate_virus_scan

      edition = create( :publication, :published,
                        alternative_format_provider: create(:organisation_with_alternative_format_contact_email),
                        attachments: [bad_attachment, good_attachment, replaced_attachment] )
      document = edition.document

      repairer = repairer_for(document)

      assert_difference('document.editions.count') do
        repairer.repair_attachments!
      end

      new_edition = document.reload.latest_edition

      assert new_edition.published?, "new edition should be published, but is currently :#{new_edition.state}"
      assert_equal 3, new_edition.attachments.size
      assert_equal 'attachment 1', new_edition.attachments[0].title
      assert_equal 'attachment 2', new_edition.attachments[1].title
      assert_equal 'whitepaper.pdf', new_edition.attachments[0].filename
      assert_equal 'greenpaper.pdf', new_edition.attachments[1].filename

      assert_equal good_attachment_data, new_edition.attachments[1].attachment_data
      assert_equal replaced_attachment_data, new_edition.attachments[2].attachment_data
    end

    test 'does not replace attachment if it has already been replaced' do
      bad_attachment = create(:file_attachment, file: double_extension_file, title: 'attachment title')
      bad_attachment.attachment_data.replaced_by = create(:file_attachment).attachment_data
      VirusScanHelpers.simulate_virus_scan

      edition = create( :publication, :published,
                        alternative_format_provider: create(:organisation_with_alternative_format_contact_email),
                        attachments: [bad_attachment] )
      document = edition.document
      repairer = repairer_for(document)

      assert_no_difference('document.editions.count') do
        repairer.repair_attachments!
      end
    end

    # # Draft editions #####

    test 'updates the attachment data of the latest edition with a renamed attachment file when the document is draft' do
      bad_attachment = create(:file_attachment, file: double_extension_file, title: 'attachment title')
      VirusScanHelpers.simulate_virus_scan

      edition = create( :publication,
                        alternative_format_provider: create(:organisation_with_alternative_format_contact_email),
                        attachments: [bad_attachment] )
      document = edition.document
      repairer = repairer_for(document)

      refute document.published?
      assert_no_difference('document.editions.count') do
        repairer.repair_attachments!
      end

      assert_equal bad_attachment, edition.reload.attachments.first

      attachment_data = edition.attachments.first.attachment_data
      VirusScanHelpers.simulate_virus_scan

      assert_equal bad_attachment.attachment_data_id, attachment_data.id
      assert_equal 'whitepaper.pdf', attachment_data.filename
      assert FileUtils.identical?(double_extension_file.path, attachment_data.file.path)
      assert_nil bad_attachment.reload.attachment_data.replaced_by

      assert_equal 'Updated with corrected attachment filename(s)', edition.editorial_remarks.last.body
    end

    # # Published editions with a newer draft #####

    test 'replaces the attachment data of the latest edition when the document is published with a newer draft' do
      bad_attachment = create(:file_attachment, file: double_extension_file, title: 'attachment title')
      VirusScanHelpers.simulate_virus_scan

      edition = create( :publication, :published,
                        alternative_format_provider: create(:organisation_with_alternative_format_contact_email),
                        attachments: [bad_attachment] )
      draft_edition = edition.create_draft(gds_team_user)
      document = edition.document

      repairer = repairer_for(document)

      assert_no_difference('document.editions.count') do
        repairer.repair_attachments!
      end

      assert document.reload.published?
      assert_equal draft_edition, document.latest_edition
      # new attachment data, replacing the old one
      new_attachment = draft_edition.reload.attachments.first
      assert_equal 'whitepaper.pdf', new_attachment.filename
      assert_equal new_attachment.attachment_data, bad_attachment.attachment_data(true).replaced_by

      assert_equal 'Updated with corrected attachment filename(s)', draft_edition.editorial_remarks.last.body
    end

    test 'does not replace newer draft edition attachment data if they have already been repaired' do
      bad_attachment = create(:file_attachment, file: double_extension_file, title: 'attachment title')
      VirusScanHelpers.simulate_virus_scan

      edition = create( :publication, :published,
                        alternative_format_provider: create(:organisation_with_alternative_format_contact_email),
                        attachments: [bad_attachment] )
      draft_edition = edition.create_draft(gds_team_user)
      document = edition.document

      repairer = repairer_for(document)

      assert_difference('AttachmentData.count') do
        repairer.repair_attachments!
      end

      new_attachment = draft_edition.reload.attachments.first
      assert_equal 'whitepaper.pdf', new_attachment.filename
      assert_equal 1, draft_edition.editorial_remarks.count
      new_attachment_data = new_attachment.attachment_data

      assert_no_difference('AttachmentData.count') do
        repairer.repair_attachments!
      end
      assert_equal new_attachment_data, draft_edition.reload.attachments.first.attachment_data
      assert_equal 1, draft_edition.editorial_remarks.count
    end

    # edge cases

    test 'documents in a collection successfully get repaired' do
      bad_attachment = create(:file_attachment, file: double_extension_file, title: 'attachment title')
      VirusScanHelpers.simulate_virus_scan

      edition = create( :publication, :published,
                        alternative_format_provider: create(:organisation_with_alternative_format_contact_email),
                        attachments: [bad_attachment])
      document = edition.document
      collection = create(:document_collection, documents: [document])
      repairer = repairer_for(document)

      assert repairer.repair_attachments!
    end

    private

    def repairer_for(document, logger=nil)
      DataHygiene::DocumentAttachmentRepairer.new(document, gds_team_user, (logger || stub_everything("Logger")))
    end

    def double_extension_file
      File.open(Rails.root.join('test', 'fixtures', 'whitepaper.pdf.pdf'))
    end

    def gds_team_user
      @gds_team_user ||= create(:gds_editor, name: "GDS Inside Government Team")
    end
  end
end
