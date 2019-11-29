require "test_helper"
require "rake"

class RepublishBrexitCtaDocumentsTest < ActiveSupport::TestCase
  setup do
    # Without this condition the test runs the rake task twice locally
    unless Rake::Task.task_defined?("republish_brexit_cta_documents")
      Rake.application.rake_require "tasks/republish_brexit_cta_documents"
    end
    Rake::Task.define_task(:environment)
    $stdout.stubs(:puts)
  end

  test "it should republish all documents with $BrexitCTA in the body" do
    edition_one = create(:published_publication, body: "Some content\n\n$BrexitCTA")
    edition_two = create(:published_publication, body: "$BrexitCTA\n\nSome content")
    edition_three = create(:published_publication, body: "$CTA\n\nSome other CTA\n\n$CTA")

    PublishingApiDocumentRepublishingWorker.expects(:perform_async_in_queue)
                                           .with("bulk_republishing", edition_one.document_id)

    PublishingApiDocumentRepublishingWorker.expects(:perform_async_in_queue)
                                           .with("bulk_republishing", edition_two.document_id)

    PublishingApiDocumentRepublishingWorker.expects(:perform_async_in_queue)
                                           .with("bulk_republishing", edition_three.document_id)
                                           .never

    Rake.application.invoke_task "republish_brexit_cta_documents"
  end
end
