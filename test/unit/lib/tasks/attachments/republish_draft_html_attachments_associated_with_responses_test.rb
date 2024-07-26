require "test_helper"
require "rake"

class RepublishDraftHtmlAttachmentsWithAssociatedResponsesRake < ActiveSupport::TestCase
  test "it republishes documents with an associated draft response which has an html attachment" do
    draft_consultation_with_outcome = create(:draft_consultation)
    draft_outcome = create(:consultation_outcome, consultation: draft_consultation_with_outcome)
    create(:html_attachment, attachable: draft_outcome)

    published_consultation_with_outcome = create(:published_consultation)
    published_outcome = create(:consultation_outcome, consultation: published_consultation_with_outcome)
    create(:html_attachment, attachable: published_outcome)

    draft_consultation_with_public_feedback = create(:draft_consultation)
    draft_feedback = create(:consultation_public_feedback, consultation: draft_consultation_with_public_feedback)
    create(:html_attachment, attachable: draft_feedback)

    published_consultation_with_public_feedback = create(:published_consultation)
    published_feedback = create(:consultation_public_feedback, consultation: published_consultation_with_public_feedback)
    create(:html_attachment, attachable: published_feedback)

    PublishingApiDocumentRepublishingWorker.expects(:perform_async_in_queue).with(
      "bulk_republishing",
      draft_consultation_with_outcome.document_id,
      true,
    )

    PublishingApiDocumentRepublishingWorker.expects(:perform_async_in_queue).with(
      "bulk_republishing",
      draft_consultation_with_public_feedback.document_id,
      true,
    )

    PublishingApiDocumentRepublishingWorker.expects(:perform_async_in_queue).with(
      "bulk_republishing",
      published_consultation_with_outcome.document_id,
      true,
    ).never

    PublishingApiDocumentRepublishingWorker.expects(:perform_async_in_queue).with(
      "bulk_republishing",
      published_consultation_with_public_feedback.document_id,
      true,
    ).never

    capture_io do
      Rake.application.invoke_task "republish_draft_html_attachments_associated_with_responses"
    end
  end
end
