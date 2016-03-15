require 'test_helper'
require 'gds_api/test_helpers/publishing_api_v2'

class PublishingApiWorkerTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::PublishingApiV2

  test "it pushes the published and then the draft editions of a document" do
    document  = create(:document, content_id: SecureRandom.uuid)
    published = create(:published_publication, title: "Published edition", document: document)
    draft     = create(:draft_edition,         title: "Draft edition",     document: document)

    presenter = PublishingApiPresenters.presenter_for(published, update_type: 'republish')
    requests = [
      stub_publishing_api_put_content(document.content_id, presenter.content),
      stub_publishing_api_patch_links(document.content_id, links: presenter.links),
      stub_publishing_api_publish(document.content_id, locale: presenter.content[:locale], update_type: 'republish')
    ]
    Whitehall::PublishingApi.expects(:save_draft_async).with(draft, 'republish')

    PublishingApiDocumentRepublishingWorker.new.perform(published.id, draft.id)

    assert_all_requested(requests)
  end

  test "it pushes all locales for the published document" do
    document  = create(:document, content_id: SecureRandom.uuid)
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

    PublishingApiDocumentRepublishingWorker.new.perform(edition.id, nil)

    assert_all_requested(requests)
    assert_requested(patch_links_request, times: 2)
  end
end
