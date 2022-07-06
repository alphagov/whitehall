require "test_helper"
require "rake"

class RepublishCsvAttachmentsRake < ActiveSupport::TestCase
  test "it republishes documents with an associated CSV attachment" do
    edition_with_csv_attachment = create(:edition)
    create(:csv_attachment, attachable: edition_with_csv_attachment)

    edition_with_deleted_csv_attachment = create(:edition)
    create(:csv_attachment, attachable: edition_with_csv_attachment, deleted: true)

    edition_with_pdf_attachment = create(:edition)
    create(:file_attachment, attachable: edition_with_pdf_attachment)

    PublishingApiDocumentRepublishingWorker.expects(:perform_async_in_queue).with(
      "bulk_republishing",
      edition_with_csv_attachment.document_id,
      true,
    )

    PublishingApiDocumentRepublishingWorker.expects(:perform_async_in_queue).with(
      "bulk_republishing",
      edition_with_deleted_csv_attachment.document_id,
      true,
    ).never

    PublishingApiDocumentRepublishingWorker.expects(:perform_async_in_queue).with(
      "bulk_republishing",
      edition_with_pdf_attachment.document_id,
      true,
    ).never

    Rake.application.invoke_task "republish_csv_attachments"
  end
end
