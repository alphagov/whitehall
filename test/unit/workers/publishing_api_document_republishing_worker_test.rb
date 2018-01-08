require 'test_helper'
require 'gds_api/test_helpers/publishing_api_v2'

class PublishingApiDocumentRepublishingWorkerTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::PublishingApiV2

  test "it pushes the published and the draft editions of a document if there is a later draft" do
    document = stub(
      published_edition: published_edition = build(:edition, id: 1),
      id: 1,
      pre_publication_edition: draft_edition = build(:edition, id: 2),
    )

    Document.stubs(:find).returns(document)

    PublishingApiWorker.expects(:new).returns(api_worker = mock)
    api_worker.expects(:perform).with(published_edition.class.name, published_edition.id, "republish", "en")

    PublishingApiDraftWorker.expects(:new).returns(draft_worker = mock)
    draft_worker.expects(:perform).with(draft_edition.class.name, draft_edition.id, "republish", "en")

    invocation_order = sequence('invocation_order')
    PublishingApiHtmlAttachmentsWorker
      .any_instance
      .expects(:perform)
      .with(published_edition.id, "republish")
      .in_sequence(invocation_order)
    PublishingApiHtmlAttachmentsWorker
      .any_instance
      .expects(:perform)
      .with(draft_edition.id, "republish")
      .in_sequence(invocation_order)

    PublishingApiDocumentRepublishingWorker.new.perform(document.id)
  end

  class PublishException < StandardError; end
  class DraftException < StandardError; end
  test "it pushes the published version first if there is a more recent draft" do
    document = stub(
      published_edition: build(:edition),
      id: 1,
      pre_publication_edition: build(:edition),
    )

    Document.stubs(:find).returns(document)

    PublishingApiWorker.stubs(:new).returns(api_worker = mock)
    api_worker.stubs(:perform).raises(PublishException)
    PublishingApiDraftWorker.stubs(:new).returns(draft_worker = mock)
    draft_worker.stubs(:perform).raises(DraftException)

    assert_raises PublishException do
      PublishingApiDocumentRepublishingWorker.new.perform(document.id)
    end
  end

  test "it pushes all locales for the published document" do
    document = create(:document, content_id: SecureRandom.uuid)
    edition = build(:published_edition, title: "Published edition", document: document)
    with_locale(:es) { edition.title = "spanish-title" }
    edition.save!

    presenter = PublishingApiPresenters.presenter_for(edition, update_type: 'republish')
    requests = [
      stub_publishing_api_put_content(document.content_id, with_locale(:en) { presenter.content }),
      stub_publishing_api_publish(document.content_id, locale: 'en', update_type: 'republish'),
      stub_publishing_api_put_content(document.content_id, with_locale(:es) { presenter.content }),
      stub_publishing_api_publish(document.content_id, locale: 'es', update_type: 'republish')
    ]
    # Have to separate this as we need to manually assert it was done twice. If
    # we split the pushing of links into a separate job, then we would only push
    # links once and could put this back into the array.
    patch_links_request = stub_publishing_api_patch_links(document.content_id, links: presenter.links)

    PublishingApiDocumentRepublishingWorker.new.perform(document.id)

    assert_all_requested(requests)
    assert_requested(patch_links_request, times: 2)
  end

  test "it runs the PublishingApiUnpublishingWorker if the latest edition has an unpublishing" do
    document = create(:document, content_id: SecureRandom.uuid)
    edition = create(:unpublished_edition, title: "Unpublished edition", document: document)
    unpublishing = edition.unpublishing

    PublishingApiUnpublishingWorker.expects(:new).returns(worker_instance = mock)
    worker_instance.expects(:perform).with(unpublishing.id, true)

    PublishingApiDocumentRepublishingWorker.new.perform(document.id)
  end

  test "it publishes and then unpublishes if the published edition is withdrawn" do
    unpublishing = build(:withdrawn_unpublishing, id: 10)
    document = stub(
      published_edition: published_edition = create(:withdrawn_edition, unpublishing: unpublishing),
      id: 1,
      pre_publication_edition: nil,
    )

    Document.stubs(:find).returns(document)
    PublishingApiWorker.expects(:new).returns(api_worker = mock)
    api_worker.expects(:perform).with(published_edition.class.name, published_edition.id, "republish", "en")

    PublishingApiUnpublishingWorker.expects(:new).returns(unpublishing_worker = mock)
    unpublishing_worker.expects(:perform).with(published_edition.unpublishing.id, false)

    invocation_order = sequence('invocation_order')
    PublishingApiHtmlAttachmentsWorker
      .any_instance
      .expects(:perform)
      .with(published_edition.id, "republish")
      .in_sequence(invocation_order)
    PublishingApiHtmlAttachmentsWorker
      .any_instance
      .expects(:perform)
      .with(published_edition.id, "republish")
      .in_sequence(invocation_order)

    PublishingApiDocumentRepublishingWorker.new.perform(document.id)
  end

  test "it raises if an unknown combination is encountered" do
    document = stub(
      published_edition: stub(id: 2, unpublishing: stub(id: 4, unpublishing_reason_id: 100)),
      id: 1,
      pre_publication_edition: nil,
    )

    Document.stubs(:find).returns(document)
    assert_raise "Document id: 1 has an unrecognised state for republishing" do
      PublishingApiDocumentRepublishingWorker.new.perform(document.id)
    end
  end

  test "it completes silently if there are no published or pre_pub editions" do
    #whitehall has a lot of old documents that only have superseded editions
    #we want to ignore these and not have to try and avoid passing them in
    #when doing bulk republishing
    document = stub(
      published_edition: nil,
      id: 1,
      pre_publication_edition: nil,
    )

    Document.stubs(:find).returns(document)

    raising_worker = mock
    raising_worker.stubs(:perform).raises

    PublishingApiWorker.stubs(:new).returns(raising_worker)
    PublishingApiDraftWorker.stubs(:new).returns(raising_worker)
    PublishingApiUnpublishingWorker.stubs(:new).returns(raising_worker)

    assert_nothing_raised do
      PublishingApiDocumentRepublishingWorker.new.perform(document.id)
    end
  end
end
