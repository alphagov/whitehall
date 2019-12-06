require "test_helper"
require "rake"

class RepublishBrexitCtaDocumentsTest < ActiveSupport::TestCase
  setup do
    unless Rake::Task.task_defined?("republish_brexit_cta_documents")
      Rake.application.rake_require "tasks/republish_brexit_cta_documents"
    end
    Rake::Task.define_task(:environment)
    Rake::Task["republish_brexit_cta_documents"].reenable
  end

  test "it should republish all documents with $BrexitCTA in the body" do
    Sidekiq::Testing.fake! do
      edition_one = create(:published_publication, body: "Some content\n\n$BrexitCTA")
      edition_two = create(:published_publication, body: "$BrexitCTA\n\nSome content")
      create(:published_publication, body: "$CTA\n\nSome other CTA\n\n$CTA")

      assert_equal(PublishingApiDocumentRepublishingWorker.jobs.size, 0)
      Rake.application.invoke_task "republish_brexit_cta_documents"
      assert_equal(PublishingApiDocumentRepublishingWorker.jobs.size, 2)

      ids = PublishingApiDocumentRepublishingWorker.jobs.map { |j| j["args"].first }
      assert_equal(ids, [edition_one.document_id, edition_two.document_id])
    end
  end
end
