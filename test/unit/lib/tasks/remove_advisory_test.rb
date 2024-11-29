require "test_helper"
require "rake"

class RemoveAdvisoryRakeTest < ActiveSupport::TestCase

  test "it updates editions with advisory govspeak surrounded by @ symbols" do
    edition = create(:published_edition, body: "@example@")
    PublishingApiDocumentRepublishingWorker.expects(:perform_async_in_queue).with(
      "bulk_republishing",
      edition.document_id,
      true,
    )

    Rake.application.invoke_task "remove_advisory:published_editions"

    assert_equal "^example^", edition.reload.body
  end

  test "it updates editions with a body starting with @ and ending with two newlines" do
    edition = create(:published_edition, body: "@example\n\n")
    PublishingApiDocumentRepublishingWorker.expects(:perform_async_in_queue).with(
      "bulk_republishing",
      edition.document_id,
      true,
    )


    Rake.application.invoke_task "remove_advisory:published_editions"

    assert_equal "^example^\n\n", edition.reload.body
  end

  test "it does not update editions with @ followed by $CTA" do
    edition = create(:published_edition, body: "@example\n\n$CTA something")
    PublishingApiDocumentRepublishingWorker.expects(:perform_async_in_queue).never

    Rake.application.invoke_task "remove_advisory:published_editions"

    assert_equal "@example\n\n$CTA something", edition.reload.body
  end

  test "dry run only outputs matching editions and does not update them" do
    edition = create(:published_edition, body: "@example@")
    attachment = create( :html_attachment,
      attachable: edition,
      body: "@example@"
    )

    Rake.application.invoke_task "remove_advisory:dry_run_published_editions"

    assert_equal "@example@", attachment.reload.body, "Dry run should not modify data"
  end
end
