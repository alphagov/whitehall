require "test_helper"
require "gds_api/test_helpers/publishing_api"

class PublishingApiDocumentRepublishingWorkerTest < ActiveSupport::TestCase
  test "should ignore old superseded editions when doing bulk republishing" do
    document = create(:document, editions: [build(:superseded_edition)])

    Whitehall::PublishingApi.expects(:publish).never
    Whitehall::PublishingApi.expects(:save_draft).never
    Whitehall::PublishingApi.expects(:locales_for).never
    Whitehall::PublishingApi.expects(:patch_links).never
    PublishingApiUnpublishingWorker.any_instance.expects(:perform).never
    ServiceListeners::PublishingApiHtmlAttachments.expects(:process).never

    PublishingApiDocumentRepublishingWorker.new.perform(document.id)
  end
end
