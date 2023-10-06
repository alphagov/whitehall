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

  it "runs the PublishingApiUnpublishingWorker if the latest edition has an unpublishing" do
    document = create(:document, content_id: SecureRandom.uuid)
    edition = create(:unpublished_edition, title: "Unpublished edition", document:)
    unpublishing = edition.unpublishing

    PublishingApiUnpublishingWorker.expects(:new).returns(worker_instance = mock)
    worker_instance.expects(:perform).with(unpublishing.id, true)

    PublishingApiDocumentRepublishingWorker.new.perform(document.id)
  end

  it "publishes and then unpublishes if the published edition is withdrawn" do
    unpublishing = build(:withdrawn_unpublishing, id: 10)
    document = stub(
      live_edition: live_edition = create(:withdrawn_edition, unpublishing:),
      id: 1,
      pre_publication_edition: nil,
      lock!: true,
    )

    Document.stubs(:find).returns(document)

    Whitehall::PublishingApi.expects(:publish).with(
      live_edition,
      "republish",
      bulk_publishing: false,
    )

    PublishingApiUnpublishingWorker.expects(:new).returns(unpublishing_worker = mock)
    unpublishing_worker.expects(:perform).with(live_edition.unpublishing.id, false)

    invocation_order = sequence("invocation_order")
    ServiceListeners::PublishingApiHtmlAttachments
      .expects(:process)
      .with(live_edition, "republish")
      .in_sequence(invocation_order)
    ServiceListeners::PublishingApiHtmlAttachments
      .expects(:process)
      .with(live_edition, "republish")
      .in_sequence(invocation_order)

    PublishingApiDocumentRepublishingWorker.new.perform(document.id)
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

  it "completes silently if there are no live or pre_publication editions" do
    # whitehall has a lot of old documents that only have superseded editions
    # we want to ignore these and not have to try and avoid passing them in
    # when doing bulk republishing
    document = stub(
      live_edition: nil,
      id: 1,
      pre_publication_edition: nil,
    )

    Document.stubs(:find).returns(document)

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
