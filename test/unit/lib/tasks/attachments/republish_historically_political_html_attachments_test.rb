require "test_helper"
require "rake"
class RepublishHistoricallyPoliticalHtmlAttachmentsRake < ActiveSupport::TestCase
  test "it republishes documents with historically political HtmlAttachments" do
    previous_government = create(:government, start_date: 5.years.ago, end_date: 1.year.ago - 1.day)
    current_government = create(:government, start_date: 1.year.ago)

    historically_political_edition = create(
      :edition,
      :with_document,
      :published,
      first_published_at: 2.years.ago,
      government: previous_government,
    )
    political_edition = create(
      :edition,
      :with_document,
      :published,
      first_published_at: 1.month.ago,
      government: current_government,
    )

    historical_edition = create(
      :edition,
      :with_document,
      :published,
      first_published_at: 5.years.ago,
    )

    unpublished_historically_political_edition = create(
      :edition,
      :with_document,
      :unpublished,
      first_published_at: 5.years.ago,
    )

    create(:html_attachment, attachable: historically_political_edition)
    create(:html_attachment, attachable: political_edition)
    create(:html_attachment, attachable: historical_edition)
    create(:html_attachment, attachable: unpublished_historically_political_edition)

    PublishingApiDocumentRepublishingWorker.expects(:perform_async_in_queue).with(
      "bulk_republishing",
      historically_political_edition.document_id,
      true,
    )

    PublishingApiDocumentRepublishingWorker.expects(:perform_async_in_queue).with(
      "bulk_republishing",
      political_edition.document_id,
      true,
    ).never

    PublishingApiDocumentRepublishingWorker.expects(:perform_async_in_queue).with(
      "bulk_republishing",
      historical_edition.document_id,
      true,
    ).never

    PublishingApiDocumentRepublishingWorker.expects(:perform_async_in_queue).with(
      "bulk_republishing",
      unpublished_historically_political_edition.document_id,
      true,
    ).never

    capture_io do
      Rake.application.invoke_task "republish_historically_political_html_attachments"
    end
  end
end
