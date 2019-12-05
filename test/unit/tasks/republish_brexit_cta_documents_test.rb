require "test_helper"
require "rake"

class RepublishBrexitCtaDocumentsTest < ActiveSupport::TestCase
  setup do
    Rake.application.rake_require "tasks/republish_brexit_cta_documents"
    $stdout.stubs(:puts)
    Rake::Task.define_task(:environment)
  end

  test "it should republish all documents with $BrexitCTA in the body" do
    edition_one = create(:published_publication, body: "Some content\n\n$BrexitCTA")
    edition_two = create(:published_publication, body: "$BrexitCTA\n\nSome content")
    edition_three = create(:published_publication, body: "$CTA\n\nSome other CTA\n\n$CTA")

    PublishingApiDocumentRepublishingWorker.expects(:perform_async_in_queue)
                                           .with("bulk_republishing", edition_one.document_id)
                                           .returns(true)

    PublishingApiDocumentRepublishingWorker.expects(:perform_async_in_queue)
                                           .with("bulk_republishing", edition_two.document_id)
                                           .returns(true)

    PublishingApiDocumentRepublishingWorker.expects(:perform_async_in_queue)
                                           .with("bulk_republishing", edition_three.document_id)
                                           .never

    Rake.application.invoke_task "republish_brexit_cta_documents"
  end
end
