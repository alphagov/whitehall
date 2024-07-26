require "test_helper"
require "rake"

class RepublishAttachmentsRake < ActiveSupport::TestCase
  setup do
    @edition_with_pdf_attachment = create(:published_edition, traits: [:with_document])
    create(:file_attachment, attachable: @edition_with_pdf_attachment)

    @edition_with_csv_attachment = create(:published_edition, traits: [:with_document])
    create(:csv_attachment, attachable: @edition_with_csv_attachment)

    @old_edition = build(:published_edition, traits: [:with_document])
    @old_edition.first_published_at = Time.zone.now - 4.weeks
    @old_edition.save!
    create(:csv_attachment, attachable: @old_edition)
  end

  teardown do
    Rake::Task["republish_attachments"].reenable # without this, calling `invoke` does nothing after first test
  end

  test "it selects documents with any attachment type to be republished by default" do
    expect_pdf_attachment.once
    expect_csv_attachment.once
    expect_old_csv_edition.once

    assert_output(/3 items to republish/) { Rake.application.invoke_task "republish_attachments" }
  end

  test "it selects documents with only the given attachment content type to be republished" do
    expect_pdf_attachment.never
    expect_csv_attachment.once
    expect_old_csv_edition.once

    assert_output(/2 items to republish/) { Rake.application.invoke_task "republish_attachments[text/csv]" }
  end

  test "it selects documents that are newer than the provided weeks_ago value" do
    expect_pdf_attachment.never
    expect_csv_attachment.once
    expect_old_csv_edition.never

    assert_output(/1 items to republish/) { Rake.application.invoke_task "republish_attachments[text/csv,3]" }
  end

  def expect_pdf_attachment
    PublishingApiDocumentRepublishingWorker.expects(:perform_async_in_queue).with(
      "bulk_republishing",
      @edition_with_pdf_attachment.document_id,
      true,
    )
  end

  def expect_csv_attachment
    PublishingApiDocumentRepublishingWorker.expects(:perform_async_in_queue).with(
      "bulk_republishing",
      @edition_with_csv_attachment.document_id,
      true,
    )
  end

  def expect_old_csv_edition
    PublishingApiDocumentRepublishingWorker.expects(:perform_async_in_queue).with(
      "bulk_republishing",
      @old_edition.document_id,
      true,
    )
  end
end
