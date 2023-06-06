require "test_helper"
require "rake"

class RepublishNationApplicableHtmlAttachmentsRake < ActiveSupport::TestCase
  test "it republishes documents with specific national applicability and a HtmlAttachment" do
    nation_inapplicability1 = create(
      :nation_inapplicability,
      nation: Nation.scotland,
      alternative_url: "http://scotland.com",
    )

    nation_inapplicability2 = create(
      :nation_inapplicability,
      nation: Nation.wales,
      alternative_url: "http://wales.com",
    )

    published_consultation_with_excluded_nations = create(
      :published_consultation_with_excluded_nations,
      nation_inapplicabilities: [
        nation_inapplicability1,
      ],
    )

    unpublished_consultation_with_excluded_nations = create(
      :consultation_with_excluded_nations,
      nation_inapplicabilities: [
        nation_inapplicability2,
      ],
    )

    published_consultation_without_excluded_nations = create(:published_consultation)

    create(:html_attachment, attachable: published_consultation_with_excluded_nations)
    create(:html_attachment, attachable: unpublished_consultation_with_excluded_nations)
    create(:html_attachment, attachable: published_consultation_without_excluded_nations)

    PublishingApiDocumentRepublishingWorker.expects(:perform_async_in_queue).with(
      "bulk_republishing",
      published_consultation_with_excluded_nations.document_id,
      true,
    )

    PublishingApiDocumentRepublishingWorker.expects(:perform_async_in_queue).with(
      "bulk_republishing",
      unpublished_consultation_with_excluded_nations.document_id,
      true,
    ).never

    PublishingApiDocumentRepublishingWorker.expects(:perform_async_in_queue).with(
      "bulk_republishing",
      published_consultation_without_excluded_nations.document_id,
      true,
    ).never

    capture_io do
      Rake.application.invoke_task "republish_nation_inapplicable_html_attachments"
    end
  end
end
