require "test_helper"
require "rake"

class MarkOrganisationAsPoliticalRake < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  teardown { task.reenable }

  describe "#mark_as_political" do
    let(:task) { Rake::Task["db:mark_as_political"] }
    let(:organisation) { create(:organisation) }
    let(:published_edition) { create(:edition, :published, organisation: organisation) }
    let(:draft_edition) { create(:edition, :draft, organisation: organisation) }

    it "raises an error if organisation does not exist" do
      e = assert_raises(StandardError) { task.invoke("n on-existent-slug") }
      assert_equal e.message, "Couldn't find Organisation"
    end

    it "marks published editions as political" do
      task.invoke(organisation.slug)
      assert published_edition.reload.political
    end

    it "marks draft editions as political" do
      task.invoke(organisation.slug)
      assert draft_edition.reload.political
    end

    it "triggers a bulk republishing of published documents" do
      PublishingApiDocumentRepublishingWorker.expects(:perform_async_in_queue).with("bulk_republishing", published_edition.document_id, true)
      task.invoke(organisation.slug)
    end

    it "does not trigger a bulk republishing of draft documents" do
      PublishingApiDocumentRepublishingWorker.expects(:perform_async_in_queue).with("bulk_republishing", draft_edition.document_id, true).never
      task.invoke(organisation.slug)
    end
  end
end