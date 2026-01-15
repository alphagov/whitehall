require "test_helper"

class DraftLocaleSwitchTest < ActiveSupport::TestCase
  test "updates Publishing API when changing primary locale of a draft" do
    edition = create(:draft_document_collection, title: "English Title", primary_locale: "en")
    edition.primary_locale = "fr"
    edition.save!

    Whitehall::PublishingApi.expects(:patch_links).at_least_once

    Whitehall::PublishingApi.expects(:save_draft_translation).with(
      anything,
      :fr,
      nil,
      bulk_publishing: false,
    )

    Whitehall::PublishingApi.expects(:discard_translation_async).with(
      anything,
      locale: "en",
    )

    DraftEditionUpdater.new(edition, current_user: create(:user)).perform!
  end

  test "does not discard translation when primary locale is unchanged" do
    edition = create(:draft_document_collection, title: "English Title", primary_locale: "en")
    edition.title = "New Title"
    edition.save!

    Whitehall::PublishingApi.expects(:patch_links).at_least_once
    Whitehall::PublishingApi.expects(:save_draft_translation).with(
      anything,
      :en,
      nil,
      bulk_publishing: false,
    )

    Whitehall::PublishingApi.expects(:discard_translation_async).never

    DraftEditionUpdater.new(edition, current_user: create(:user)).perform!
  end
end
