require "test_helper"
require "rake"

class MarkDocumentsAsPoliticalFor < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  teardown { task.reenable }

  describe "#mark_as_political" do
    let(:task) { Rake::Task["election:mark_documents_as_political_for"] }
    let(:organisation) { create(:organisation) }
    let(:document) { create(:document) }
    let(:published_edition) { create(:edition, :published, document:) }
    let(:draft_edition) { create(:edition, :draft, document:) }

    setup do
      organisation.editions = [published_edition, draft_edition]
      organisation.save!
    end

    it "raises an error if organisation does not exist" do
      out, _err = capture_io { task.invoke("non-existent-slug") }
      assert_equal 'There is no Organisation with slug ["non-existent-slug"]', out.strip
    end

    it "marks published and draft editions as political" do
      capture_io { task.invoke(organisation.slug) }
      assert published_edition.reload.political
      assert draft_edition.reload.political
    end

    it "triggers a bulk republishing of published documents" do
      PublishingApiDocumentRepublishingWorker.expects(:perform_async_in_queue).with("bulk_republishing", published_edition.document_id, true)
      capture_io { task.invoke(organisation.slug) }
    end
  end
end
