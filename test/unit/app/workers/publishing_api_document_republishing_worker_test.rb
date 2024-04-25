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

    context "when there are non-superseded editions" do
      test "unpublishes the latest unpublished edition when the document has been unpublished" do
        first_unpublished_edition = build(:unpublished_edition)
        last_unpublished_edition = build(:unpublished_edition)
        document = create(:document, editions: [first_unpublished_edition, last_unpublished_edition])

        PublishingApiUnpublishingWorker.any_instance.expects(:perform).with(last_unpublished_edition.unpublishing.id, last_unpublished_edition.draft?).once
        ServiceListeners::PublishingApiAssociatedDocuments.expects(:process).with(last_unpublished_edition, "republish").once
        Whitehall::PublishingApi.expects(:save_draft).never
        Whitehall::PublishingApi.expects(:publish).never
        Whitehall::PublishingApi.expects(:patch_links).never

        PublishingApiDocumentRepublishingWorker.new.perform(document.id)
      end

      test "unpublishes the latest unpublished edition and draft edition when the document has been unpublished and there's also a draft edition" do
        first_unpublished_edition = build(:unpublished_edition)
        last_unpublished_edition = build(:unpublished_edition)
        draft_edition = build(:draft_edition)
        document = create(:document, editions: [first_unpublished_edition, last_unpublished_edition, draft_edition])

        PublishingApiUnpublishingWorker.any_instance.expects(:perform).with(last_unpublished_edition.unpublishing.id, last_unpublished_edition.draft?).once
        ServiceListeners::PublishingApiAssociatedDocuments.expects(:process).with(last_unpublished_edition, "republish").once
        Whitehall::PublishingApi.expects(:save_draft).with(draft_edition, "republish", bulk_publishing: false).once
        ServiceListeners::PublishingApiAssociatedDocuments.expects(:process).with(draft_edition, "republish").once
        Whitehall::PublishingApi.expects(:publish).never
        Whitehall::PublishingApi.expects(:patch_links).never

        PublishingApiDocumentRepublishingWorker.new.perform(document.id)
      end

      test "republishes then unpublishes the live edition when the document has not been unpublished but has been withdrawn" do
        live_withdrawn_edition = build(:withdrawn_edition)
        document = create(:document, live_edition: live_withdrawn_edition, editions: [live_withdrawn_edition])

        Whitehall::PublishingApi.expects(:publish).with(live_withdrawn_edition, "republish", bulk_publishing: false).once
        ServiceListeners::PublishingApiAssociatedDocuments.expects(:process).with(live_withdrawn_edition, "republish").once
        PublishingApiUnpublishingWorker.any_instance.expects(:perform).with(live_withdrawn_edition.unpublishing.id, live_withdrawn_edition.draft?).once
        ServiceListeners::PublishingApiAssociatedDocuments.expects(:process).with(live_withdrawn_edition, "republish").once
        Whitehall::PublishingApi.expects(:save_draft).never
        Whitehall::PublishingApi.expects(:patch_links).never

        PublishingApiDocumentRepublishingWorker.new.perform(document.id)
      end

      context "when the document has not been unpublished or withdrawn" do
        test "patches links then republishes the draft edition when there's only a draft edition" do
          draft_edition = build(:draft_edition)
          document = create(:document, editions: [draft_edition])

          Whitehall::PublishingApi.expects(:patch_links).with(draft_edition, bulk_publishing: false).once
          Whitehall::PublishingApi.expects(:save_draft).with(draft_edition, "republish", bulk_publishing: false).once
          ServiceListeners::PublishingApiAssociatedDocuments.expects(:process).with(draft_edition, "republish").once
          Whitehall::PublishingApi.expects(:publish).never
          PublishingApiUnpublishingWorker.any_instance.expects(:perform).never

          PublishingApiDocumentRepublishingWorker.new.perform(document.id)
        end

        test "patches links then republishes the live edition when there's only a live edition" do
          live_edition = build(:published_edition)
          document = create(:document, live_edition:, editions: [live_edition])

          Whitehall::PublishingApi.expects(:patch_links).with(live_edition, bulk_publishing: false).once
          Whitehall::PublishingApi.expects(:publish).with(live_edition, "republish", bulk_publishing: false).once
          ServiceListeners::PublishingApiAssociatedDocuments.expects(:process).with(live_edition, "republish").once
          Whitehall::PublishingApi.expects(:save_draft).never
          PublishingApiUnpublishingWorker.any_instance.expects(:perform).never

          PublishingApiDocumentRepublishingWorker.new.perform(document.id)
        end

        test "patches links with the live edition then republishes the live edition then republishes the draft edition when there's both a live and draft edition" do
          live_edition = build(:published_edition)
          draft_edition = build(:draft_edition)
          document = create(:document, live_edition:, editions: [live_edition, draft_edition])

          Whitehall::PublishingApi.expects(:patch_links).with(live_edition, bulk_publishing: false).once
          Whitehall::PublishingApi.expects(:publish).with(live_edition, "republish", bulk_publishing: false).once
          ServiceListeners::PublishingApiAssociatedDocuments.expects(:process).with(live_edition, "republish").once
          Whitehall::PublishingApi.expects(:save_draft).with(draft_edition, "republish", bulk_publishing: false).once
          ServiceListeners::PublishingApiAssociatedDocuments.expects(:process).with(draft_edition, "republish").once
          PublishingApiUnpublishingWorker.any_instance.expects(:perform).never

          PublishingApiDocumentRepublishingWorker.new.perform(document.id)
        end
      end
    end
  end
end
