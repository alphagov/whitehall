require "test_helper"
require "gds_api/test_helpers/publishing_api"

class PublishingApiDocumentRepublishingWorkerTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL
  include GdsApi::TestHelpers::PublishingApi

  let(:document) { create(:document, editions: [live_edition, draft_edition].compact) }

  context "when the document has a published edition and a draft edition" do
    let(:live_edition) { build(:published_edition) }
    let(:draft_edition) { build(:draft_edition) }

    it "publishes the live edition, then pushes the draft" do
      # This sequence asserts that the Publishing API is called in the correct order.
      # It's important to republish the 'published' edition first, then push the draft afterwards.
      publish_then_draft = sequence("publish_then_draft")

      Whitehall::PublishingApi
        .expects(:patch_links)
        .with(live_edition, bulk_publishing: false)

      Whitehall::PublishingApi
        .expects(:publish)
        .with(live_edition, "republish", bulk_publishing: false)
        .in_sequence(publish_then_draft)

      ServiceListeners::PublishingApiHtmlAttachments
        .expects(:process)
        .with(live_edition, "republish")
        .in_sequence(publish_then_draft)

      Whitehall::PublishingApi
        .expects(:save_draft)
        .with(draft_edition, "republish", bulk_publishing: false)
        .in_sequence(publish_then_draft)

      ServiceListeners::PublishingApiHtmlAttachments
        .expects(:process)
        .with(draft_edition, "republish")
        .in_sequence(publish_then_draft)

      PublishingApiDocumentRepublishingWorker.new.perform(document.id)
    end
  end

  context "when the document is published with no draft" do
    let(:live_edition) { build(:published_edition) }
    let(:draft_edition) { nil }

    it "publishes the live edition" do
      Whitehall::PublishingApi
        .expects(:patch_links)
        .with(live_edition, bulk_publishing: false)

      Whitehall::PublishingApi
        .expects(:publish)
        .with(live_edition, "republish", bulk_publishing: false)

      ServiceListeners::PublishingApiHtmlAttachments
        .expects(:process)
        .with(live_edition, "republish")

      PublishingApiDocumentRepublishingWorker.new.perform(document.id)
    end
  end

  context "when the document is draft and there is no published edition" do
    let(:live_edition) { nil }
    let(:draft_edition) { build(:draft_edition) }

    it "pushes the draft edition" do
      Whitehall::PublishingApi
        .expects(:patch_links)
        .with(draft_edition, bulk_publishing: false)

      Whitehall::PublishingApi
        .expects(:save_draft)
        .with(draft_edition, "republish", bulk_publishing: false)

      ServiceListeners::PublishingApiHtmlAttachments
        .expects(:process)
        .with(draft_edition, "republish")

      PublishingApiDocumentRepublishingWorker.new.perform(document.id)
    end
  end

  context "when the document has been withdrawn" do
    let(:live_edition) { build(:withdrawn_edition) }
    let(:draft_edition) { nil }

    it "publishes the live edition, then immediately withdraws it" do
      publish_then_withdraw = sequence("publish_then_withdraw")

      Whitehall::PublishingApi
        .expects(:patch_links)
        .with(live_edition, bulk_publishing: false)

      PublishingApiUnpublishingWorker
        .expects(:new)
        .returns(unpublishing_worker = mock)

      # 1. Republish as 'published'
      Whitehall::PublishingApi
        .expects(:publish)
        .with(live_edition, "republish", bulk_publishing: false)
        .in_sequence(publish_then_withdraw)

      # 2. Republish HTML attachments as 'published'
      ServiceListeners::PublishingApiHtmlAttachments
        .expects(:process)
        .with(live_edition, "republish")
        .in_sequence(publish_then_withdraw)

      # 3. Withdraw the newly published edition
      unpublishing_worker
        .expects(:perform)
        .with(document.live_edition.unpublishing.id, false)
        .in_sequence(publish_then_withdraw)

      # 4. Withdraw HTML attachments
      ServiceListeners::PublishingApiHtmlAttachments
        .expects(:process)
        .with(live_edition, "republish")
        .in_sequence(publish_then_withdraw)

      PublishingApiDocumentRepublishingWorker.new.perform(document.id)
    end
  end

  context "when the document has been unpublished" do
    let(:live_edition) { build(:unpublished_edition) }
    let(:draft_edition) { nil }

    it "unpublishes the document" do
      unpublish = sequence("unpublish")

      PublishingApiUnpublishingWorker
        .expects(:new)
        .returns(unpublishing_worker = mock)

      # 1. Re-send the unpublishing
      unpublishing_worker
        .expects(:perform)
        .with(document.latest_edition.unpublishing.id, false)
        .in_sequence(unpublish)

      # 2. Push HTML attachments
      ServiceListeners::PublishingApiHtmlAttachments
        .expects(:process)
        .with(document.latest_edition, "republish")
        .in_sequence(unpublish)

      PublishingApiDocumentRepublishingWorker.new.perform(document.id)
    end
  end

  context "when the document has been unpublished, and it has a new draft" do
    let(:live_edition) { build(:unpublished_edition) }
    let(:draft_edition) { build(:draft_edition) }

    it "unpublishes the document, then pushes the new draft" do
      unpublish_then_send_draft = sequence("unpublish_then_send_draft")

      Whitehall::PublishingApi
        .expects(:patch_links)
        .with(document.latest_edition, bulk_publishing: false)

      PublishingApiUnpublishingWorker
        .expects(:new)
        .returns(unpublishing_worker = mock)

      unpublished_edition = document.editions.unpublished.last

      # 1. Re-send the unpublishing
      unpublishing_worker
        .expects(:perform)
        .with(unpublished_edition.unpublishing.id, false)
        .in_sequence(unpublish_then_send_draft)

      # 2. Push HTML attachments
      ServiceListeners::PublishingApiHtmlAttachments
        .expects(:process)
        .with(unpublished_edition, "republish")
        .in_sequence(unpublish_then_send_draft)

      # 3. Push draft edition
      Whitehall::PublishingApi
        .expects(:save_draft)
        .with(draft_edition, "republish", bulk_publishing: false)
        .in_sequence(unpublish_then_send_draft)

      # 4. Push HTML attachments again
      ServiceListeners::PublishingApiHtmlAttachments
        .expects(:process)
        .with(draft_edition, "republish")
        .in_sequence(unpublish_then_send_draft)

      PublishingApiDocumentRepublishingWorker.new.perform(document.id)
    end
  end

  it "pushes all locales for the published document" do
    document = create(:document)
    edition = build(:published_edition, title: "Published edition", document:)
    with_locale(:es) { edition.title = "spanish-title" }
    edition.save!

    presenter = PublishingApiPresenters.presenter_for(edition, update_type: "republish")
    requests = [
      stub_publishing_api_put_content(document.content_id, with_locale(:en) { presenter.content }),
      stub_publishing_api_publish(document.content_id, locale: "en", update_type: nil),
      stub_publishing_api_put_content(document.content_id, with_locale(:es) { presenter.content }),
      stub_publishing_api_publish(document.content_id, locale: "es", update_type: nil),
      stub_publishing_api_patch_links(document.content_id, links: presenter.links),
    ]

    PublishingApiDocumentRepublishingWorker.new.perform(document.id)

    assert_all_requested(requests)
  end

  it "raises if an unknown combination is encountered" do
    document = build(:document,
                     live_edition: build(:edition, id: 2, unpublishing: build(:unpublishing, id: 4, unpublishing_reason_id: 100)),
                     id: 1,
                     pre_publication_edition: nil)

    Document.stubs(:find).returns(document)
    assert_raise "Document id: 1 has an unrecognised state for republishing" do
      PublishingApiDocumentRepublishingWorker.new.perform(document.id)
    end
  end

  it "completes silently if there are no editions to republish" do
    # whitehall has a lot of old documents that only have superseded editions
    # we want to ignore these and not have to try and avoid passing them in
    # when doing bulk republishing
    document = create(:document, editions: [build(:superseded_edition)])

    Whitehall::PublishingApi.stubs(:publish).raises
    Whitehall::PublishingApi.stubs(:save_draft).raises

    raising_worker = mock
    raising_worker.stubs(:perform).raises
    PublishingApiUnpublishingWorker.stubs(:new).returns(raising_worker)

    assert_nothing_raised do
      PublishingApiDocumentRepublishingWorker.new.perform(document.id)
    end
  end
end
