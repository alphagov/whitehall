require "test_helper"
require "gds_api/test_helpers/publishing_api"

class PublishingApiDocumentRepublishingWorkerTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let(:unpublished_edition_a) { build(:unpublished_edition) }
  let(:unpublished_edition_b) { build(:unpublished_edition) }
  let(:withdrawn_edition) { build(:withdrawn_edition) }
  let(:published_edition) { build(:published_edition) }
  let(:draft_edition) { build(:draft_edition) }

  let(:document) { build(:document, live_edition:, pre_publication_edition:) }

  setup do
    Document.stubs(:find).returns(document)
  end

  context "#perform" do
    context "when the document only has superseded editions" do
      let(:live_edition) { nil }
      let(:pre_publication_edition) { nil }

      setup { document.editions.stubs(:unpublished).returns([]) }

      it "does nothing" do
        Whitehall::PublishingApi.expects(:publish).never
        Whitehall::PublishingApi.expects(:save_draft).never
        Whitehall::PublishingApi.expects(:patch_links).never
        PublishingApiUnpublishingWorker.any_instance.expects(:perform).never
        ServiceListeners::PublishingApiAssociatedDocuments.expects(:process).never

        PublishingApiDocumentRepublishingWorker.new.perform(document.id)
      end
    end

    context "when the document has one or more non-superseded editions" do
      context "that are unpublished" do
        let(:live_edition) { nil }
        let(:pre_publication_edition) { nil }

        setup { document.editions.stubs(:unpublished).returns([unpublished_edition_a, unpublished_edition_b]) }

        it "refreshes the latest unpublished edition" do
          sequence = sequence("unpublish; handle attachments")

          PublishingApiUnpublishingWorker
            .any_instance
            .expects(:perform)
            .with(unpublished_edition_b.unpublishing.id, unpublished_edition_b.draft?)
            .once
            .in_sequence(sequence)
          ServiceListeners::PublishingApiAssociatedDocuments
            .expects(:process)
            .with(unpublished_edition_b, "republish")
            .once
            .in_sequence(sequence)

          Whitehall::PublishingApi.expects(:save_draft).never
          Whitehall::PublishingApi.expects(:publish).never
          Whitehall::PublishingApi.expects(:patch_links).never

          PublishingApiDocumentRepublishingWorker.new.perform(document.id)
        end

        context "and there's also a draft edition" do
          let(:live_edition) { nil }
          let(:pre_publication_edition) { draft_edition }

          setup { document.editions.stubs(:unpublished).returns([unpublished_edition_a, unpublished_edition_b]) }

          it "refreshes the latest unpublished edition and the draft edition" do
            sequence = sequence("unpublish; handle unpublished attachments; save draft; handle draft attachments")

            PublishingApiUnpublishingWorker
              .any_instance
              .expects(:perform)
              .with(unpublished_edition_b.unpublishing.id, unpublished_edition_b.draft?)
              .once
              .in_sequence(sequence)
            ServiceListeners::PublishingApiAssociatedDocuments
              .expects(:process)
              .with(unpublished_edition_b, "republish")
              .once
              .in_sequence(sequence)
            Whitehall::PublishingApi
              .expects(:save_draft)
              .with(draft_edition, "republish", bulk_publishing: false)
              .once
              .in_sequence(sequence)
            ServiceListeners::PublishingApiAssociatedDocuments
              .expects(:process)
              .with(draft_edition, "republish")
              .once
              .in_sequence(sequence)

            Whitehall::PublishingApi.expects(:publish).never
            Whitehall::PublishingApi.expects(:patch_links).never

            PublishingApiDocumentRepublishingWorker.new.perform(document.id)
          end

          it "allows for bulk publishing" do
            sequence = sequence("unpublish; handle unpublished attachments; save draft; handle draft attachments")

            PublishingApiUnpublishingWorker
              .any_instance
              .expects(:perform)
              .with(unpublished_edition_b.unpublishing.id, unpublished_edition_b.draft?)
              .once
              .in_sequence(sequence)
            ServiceListeners::PublishingApiAssociatedDocuments
              .expects(:process)
              .with(unpublished_edition_b, "republish")
              .once
              .in_sequence(sequence)
            Whitehall::PublishingApi
              .expects(:save_draft)
              .with(draft_edition, "republish", bulk_publishing: true)
              .once
              .in_sequence(sequence)
            ServiceListeners::PublishingApiAssociatedDocuments
              .expects(:process)
              .with(draft_edition, "republish")
              .once
              .in_sequence(sequence)

            Whitehall::PublishingApi.expects(:publish).never
            Whitehall::PublishingApi.expects(:patch_links).never

            PublishingApiDocumentRepublishingWorker.new.perform(document.id, true)
          end

          context "but the draft edition is invalid" do
            setup { draft_edition.stubs(:valid?).returns(false) }

            it "refreshes the latest unpublished edition but not the draft edition" do
              sequence = sequence("unpublish; handle unpublished attachments")

              PublishingApiUnpublishingWorker
                .any_instance
                .expects(:perform)
                .with(unpublished_edition_b.unpublishing.id, unpublished_edition_b.draft?)
                .once
                .in_sequence(sequence)
              ServiceListeners::PublishingApiAssociatedDocuments
                .expects(:process)
                .with(unpublished_edition_b, "republish")
                .once
                .in_sequence(sequence)

              Whitehall::PublishingApi.expects(:save_draft).never
              ServiceListeners::PublishingApiAssociatedDocuments.expects(:process).with(draft_edition, "republish").never
              Whitehall::PublishingApi.expects(:publish).never
              Whitehall::PublishingApi.expects(:patch_links).never

              PublishingApiDocumentRepublishingWorker.new.perform(document.id)
            end
          end
        end
      end

      context "and the live edition is withdrawn" do
        let(:live_edition) { withdrawn_edition }
        let(:pre_publication_edition) { nil }

        setup { document.editions.stubs(:unpublished).returns([]) }

        it "refreshes the withdrawn edition" do
          sequence = sequence("republish; handle attachments; unpublish; handle attachments")

          Whitehall::PublishingApi
            .expects(:publish)
            .with(withdrawn_edition, "republish", bulk_publishing: false)
            .once
            .in_sequence(sequence)
          ServiceListeners::PublishingApiAssociatedDocuments
            .expects(:process)
            .with(withdrawn_edition, "republish")
            .once
            .in_sequence(sequence)
          PublishingApiUnpublishingWorker
            .any_instance
            .expects(:perform)
            .with(withdrawn_edition.unpublishing.id, withdrawn_edition.draft?)
            .once
            .in_sequence(sequence)
          ServiceListeners::PublishingApiAssociatedDocuments
            .expects(:process)
            .with(withdrawn_edition, "republish")
            .once
            .in_sequence(sequence)

          Whitehall::PublishingApi.expects(:save_draft).never
          Whitehall::PublishingApi.expects(:patch_links).never

          PublishingApiDocumentRepublishingWorker.new.perform(document.id)
        end

        it "allows for bulk publishing" do
          sequence = sequence("republish; handle attachments; unpublish; handle attachments")

          Whitehall::PublishingApi
            .expects(:publish)
            .with(withdrawn_edition, "republish", bulk_publishing: true)
            .once
            .in_sequence(sequence)
          ServiceListeners::PublishingApiAssociatedDocuments
            .expects(:process)
            .with(withdrawn_edition, "republish")
            .once
            .in_sequence(sequence)
          PublishingApiUnpublishingWorker
            .any_instance
            .expects(:perform)
            .with(withdrawn_edition.unpublishing.id, withdrawn_edition.draft?)
            .once
            .in_sequence(sequence)
          ServiceListeners::PublishingApiAssociatedDocuments
            .expects(:process)
            .with(withdrawn_edition, "republish")
            .once
            .in_sequence(sequence)

          Whitehall::PublishingApi.expects(:save_draft).never
          Whitehall::PublishingApi.expects(:patch_links).never

          PublishingApiDocumentRepublishingWorker.new.perform(document.id, true)
        end
      end

      context "none of which are unpublished or withdrawn" do
        let(:live_edition) { nil }
        let(:pre_publication_edition) { draft_edition }

        context "and there's only a draft edition" do
          setup { document.editions.stubs(:unpublished).returns([]) }

          it "patches links for, then refreshes, the draft edition" do
            sequence = sequence("patch links; save; handle attachments")

            Whitehall::PublishingApi
              .expects(:patch_links)
              .with(draft_edition, bulk_publishing: false)
              .once
              .in_sequence(sequence)
            Whitehall::PublishingApi
              .expects(:save_draft)
              .with(draft_edition, "republish", bulk_publishing: false)
              .once
              .in_sequence(sequence)
            ServiceListeners::PublishingApiAssociatedDocuments
              .expects(:process)
              .with(draft_edition, "republish")
              .once
              .in_sequence(sequence)

            Whitehall::PublishingApi.expects(:publish).never
            PublishingApiUnpublishingWorker.any_instance.expects(:perform).never

            PublishingApiDocumentRepublishingWorker.new.perform(document.id)
          end

          it "allows for bulk publishing" do
            sequence = sequence("patch links; save; handle attachments")

            Whitehall::PublishingApi
              .expects(:patch_links)
              .with(draft_edition, bulk_publishing: true)
              .once
              .in_sequence(sequence)
            Whitehall::PublishingApi
              .expects(:save_draft)
              .with(draft_edition, "republish", bulk_publishing: true)
              .once
              .in_sequence(sequence)
            ServiceListeners::PublishingApiAssociatedDocuments
              .expects(:process)
              .with(draft_edition, "republish")
              .once
              .in_sequence(sequence)

            Whitehall::PublishingApi.expects(:publish).never
            PublishingApiUnpublishingWorker.any_instance.expects(:perform).never

            PublishingApiDocumentRepublishingWorker.new.perform(document.id, true)
          end

          context "but the draft edition is invalid" do
            setup { draft_edition.stubs(:valid?).returns(false) }

            it "patches links for, but doesn't refresh, the draft edition" do
              Whitehall::PublishingApi
                .expects(:patch_links)
                .with(draft_edition, bulk_publishing: false)
                .once

              Whitehall::PublishingApi.expects(:save_draft).never
              ServiceListeners::PublishingApiAssociatedDocuments.expects(:process).never
              Whitehall::PublishingApi.expects(:publish).never
              PublishingApiUnpublishingWorker.any_instance.expects(:perform).never

              PublishingApiDocumentRepublishingWorker.new.perform(document.id)
            end
          end
        end

        context "and there's only a published edition" do
          let(:live_edition) { published_edition }
          let(:pre_publication_edition) { nil }

          setup { document.editions.stubs(:unpublished).returns([]) }

          it "patches links for, then refreshes, the published edition" do
            sequence = sequence("patch links; republish; handle attachments")

            Whitehall::PublishingApi
              .expects(:patch_links)
              .with(published_edition, bulk_publishing: false)
              .once
              .in_sequence(sequence)
            Whitehall::PublishingApi
              .expects(:publish)
              .with(published_edition, "republish", bulk_publishing: false)
              .once
              .in_sequence(sequence)
            ServiceListeners::PublishingApiAssociatedDocuments
              .expects(:process)
              .with(published_edition, "republish")
              .once
              .in_sequence(sequence)

            Whitehall::PublishingApi.expects(:save_draft).never
            PublishingApiUnpublishingWorker.any_instance.expects(:perform).never

            PublishingApiDocumentRepublishingWorker.new.perform(document.id)
          end

          it "allows for bulk publishing" do
            sequence = sequence("patch links; republish; handle attachments")

            Whitehall::PublishingApi
              .expects(:patch_links)
              .with(published_edition, bulk_publishing: true)
              .once
              .in_sequence(sequence)
            Whitehall::PublishingApi
              .expects(:publish)
              .with(published_edition, "republish", bulk_publishing: true)
              .once
              .in_sequence(sequence)
            ServiceListeners::PublishingApiAssociatedDocuments
              .expects(:process)
              .with(published_edition, "republish")
              .once
              .in_sequence(sequence)

            Whitehall::PublishingApi.expects(:save_draft).never
            PublishingApiUnpublishingWorker.any_instance.expects(:perform).never

            PublishingApiDocumentRepublishingWorker.new.perform(document.id, true)
          end
        end

        context "and there's both a published and draft edition" do
          let(:live_edition) { published_edition }
          let(:pre_publication_edition) { draft_edition }

          setup { document.editions.stubs(:unpublished).returns([]) }

          it "patches links for the published edition, then refreshes the published then draft editions" do
            sequence = sequence("patch links; republish live edition; handle live attachments; save draft; handle draft attachments")

            Whitehall::PublishingApi
              .expects(:patch_links)
              .with(published_edition, bulk_publishing: false)
              .once
              .in_sequence(sequence)
            Whitehall::PublishingApi
              .expects(:publish)
              .with(published_edition, "republish", bulk_publishing: false)
              .once
              .in_sequence(sequence)
            ServiceListeners::PublishingApiAssociatedDocuments
              .expects(:process)
              .with(published_edition, "republish")
              .once
              .in_sequence(sequence)
            Whitehall::PublishingApi
              .expects(:save_draft)
              .with(draft_edition, "republish", bulk_publishing: false)
              .once
              .in_sequence(sequence)
            ServiceListeners::PublishingApiAssociatedDocuments
              .expects(:process)
              .with(draft_edition, "republish")
              .once
              .in_sequence(sequence)

            PublishingApiUnpublishingWorker.any_instance.expects(:perform).never

            PublishingApiDocumentRepublishingWorker.new.perform(document.id)
          end

          it "allows for bulk publishing" do
            sequence = sequence("patch links; republish live edition; handle live attachments; save draft; handle draft attachments")

            Whitehall::PublishingApi
              .expects(:patch_links)
              .with(published_edition, bulk_publishing: true)
              .once
              .in_sequence(sequence)
            Whitehall::PublishingApi
              .expects(:publish)
              .with(published_edition, "republish", bulk_publishing: true)
              .once
              .in_sequence(sequence)
            ServiceListeners::PublishingApiAssociatedDocuments
              .expects(:process)
              .with(published_edition, "republish")
              .once
              .in_sequence(sequence)
            Whitehall::PublishingApi
              .expects(:save_draft)
              .with(draft_edition, "republish", bulk_publishing: true)
              .once
              .in_sequence(sequence)
            ServiceListeners::PublishingApiAssociatedDocuments
              .expects(:process)
              .with(draft_edition, "republish")
              .once
              .in_sequence(sequence)

            PublishingApiUnpublishingWorker.any_instance.expects(:perform).never

            PublishingApiDocumentRepublishingWorker.new.perform(document.id, true)
          end

          context "but the draft edition is invalid" do
            setup { draft_edition.stubs(:valid?).returns(false) }

            it "patches links for, then refreshes, the published edition, but not the draft edition" do
              sequence = sequence("patch links; republish live edition; handle live attachments")

              Whitehall::PublishingApi
                .expects(:patch_links)
                .with(published_edition, bulk_publishing: false)
                .once
                .in_sequence(sequence)
              Whitehall::PublishingApi
                .expects(:publish)
                .with(published_edition, "republish", bulk_publishing: false)
                .once
                .in_sequence(sequence)
              ServiceListeners::PublishingApiAssociatedDocuments
                .expects(:process)
                .with(published_edition, "republish")
                .once
                .in_sequence(sequence)

              Whitehall::PublishingApi.expects(:save_draft).never
              ServiceListeners::PublishingApiAssociatedDocuments.expects(:process).with(draft_edition, "republish").never
              PublishingApiUnpublishingWorker.any_instance.expects(:perform).never

              PublishingApiDocumentRepublishingWorker.new.perform(document.id)
            end
          end
        end
      end
    end
  end
end
