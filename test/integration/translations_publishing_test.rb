require "test_helper"
require "gds_api/test_helpers/publishing_api"

class TranslationsPublishingTest < ActiveSupport::TestCase
  test "should not send any unpublishings to Publishing API after translations removed and draft saved" do
    edition = build(:published_detailed_guide)
    with_locale(:es) { edition.title = "spanish-title" }
    edition.save!
    draft_edition = edition.create_draft(build(:user))
    draft_edition.change_note = "change-note"
    draft_edition.save!

    draft_publication_presenter = PublishingApiPresenters.presenter_for(draft_edition)

    WebMock.reset!

    requests = [
      stub_publishing_api_put_content(draft_publication_presenter.content_id, with_locale(:en) { draft_publication_presenter.content }),
    ]

    draft_edition.translations.where(locale: :es).first.destroy!
    Whitehall.edition_services.draft_updater(draft_edition).perform!

    assert_all_requested(requests)
  end
end
