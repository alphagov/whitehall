require "test_helper"
require "gds_api/test_helpers/publishing_api"

class PublishingApiDocumentRepublishingWorkerTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  context "#perform" do
    test "does nothing when the document only has superseded editions" do
      document = create(:document, editions: [build(:superseded_edition)])

      Whitehall::PublishingApi.expects(:publish).never
      Whitehall::PublishingApi.expects(:save_draft).never
      Whitehall::PublishingApi.expects(:patch_links).never
      PublishingApiUnpublishingWorker.any_instance.expects(:perform).never
      ServiceListeners::PublishingApiAssociatedDocuments.expects(:process).never

      PublishingApiDocumentRepublishingWorker.new.perform(document.id)
    end
  end
end
