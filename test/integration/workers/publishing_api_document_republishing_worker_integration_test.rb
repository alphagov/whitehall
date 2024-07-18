require "test_helper"
require "gds_api/test_helpers/publishing_api"

# Integration Tests to check for what actual HTTP calls are being made to Publishing API by the Document Republishing Worker
class PublishingApiDocumentRepublishingWorkerIntegrationTest < ActiveSupport::TestCase
  ### Never before published documents ###
  test "should update the draft edition with all locales when document only has draft" do
    draft_edition = build(:draft_publication)
    with_locale(:es) { draft_edition.title = "spanish-title" }
    draft_edition.save!

    draft_publication_presenter = PublishingApiPresenters.presenter_for(draft_edition, update_type: "republish")
    draft_html_attachment_presenter = PublishingApiPresenters.presenter_for(draft_edition.attachments.first, update_type: "republish")

    WebMock.reset!

    expected_requests = [
      stub_publishing_api_patch_links(draft_publication_presenter.content_id, links: draft_publication_presenter.links),
      stub_publishing_api_put_content(draft_publication_presenter.content_id, with_locale(:en) { draft_publication_presenter.content }),
      stub_publishing_api_put_content(draft_publication_presenter.content_id, with_locale(:es) { draft_publication_presenter.content }),
      stub_publishing_api_put_content(draft_html_attachment_presenter.content_id, draft_html_attachment_presenter.content),
    ]

    PublishingApiDocumentRepublishingWorker.new.perform(draft_edition.document.id)

    assert_all_requested(expected_requests)
  end

  test "Should only patch links when document only has invalid draft" do
    draft_edition = create(:draft_publication)
    draft_edition.title = nil
    draft_edition.save!(validate: false)

    draft_publication_presenter = PublishingApiPresenters.presenter_for(draft_edition, update_type: "republish")

    WebMock.reset!

    expected_requests = [
      stub_publishing_api_patch_links(draft_publication_presenter.content_id, links: draft_publication_presenter.links),
    ]

    PublishingApiDocumentRepublishingWorker.new.perform(draft_edition.document.id)
    assert_all_requested(expected_requests)
  end
  ###########################

  ### Published documents ###
  test "Should publish live edition with all locales when document is published with no draft" do
    edition = build(:published_publication)
    with_locale(:es) { edition.title = "spanish-title" }
    edition.save!

    publication_presenter = PublishingApiPresenters.presenter_for(edition, update_type: "republish")
    html_attachment_presenter = PublishingApiPresenters.presenter_for(edition.attachments.first, update_type: "republish")

    WebMock.reset!

    requests = [
      stub_publishing_api_patch_links(publication_presenter.content_id, links: publication_presenter.links),
      stub_publishing_api_put_content(publication_presenter.content_id, with_locale(:en) { publication_presenter.content }),
      stub_publishing_api_put_content(publication_presenter.content_id, with_locale(:es) { publication_presenter.content }),
      stub_publishing_api_publish(publication_presenter.content_id, locale: "en", update_type: nil),
      stub_publishing_api_publish(publication_presenter.content_id, locale: "es", update_type: nil),
      stub_publishing_api_put_content(html_attachment_presenter.content_id, html_attachment_presenter.content),
      stub_publishing_api_patch_links(html_attachment_presenter.content_id, links: html_attachment_presenter.links),
      stub_publishing_api_publish(html_attachment_presenter.content_id, locale: "en", update_type: nil),
    ]

    PublishingApiDocumentRepublishingWorker.new.perform(edition.document.id)

    assert_all_requested(requests)
  end

  test "Should publish live edition and update draft with all locales when document is published with new draft" do
    edition = build(:published_publication)
    with_locale(:es) { edition.title = "spanish-title" }
    edition.save!
    draft_edition = edition.create_draft(build(:user))
    draft_edition.change_note = "change-note"
    draft_edition.save!

    publication_presenter = PublishingApiPresenters.presenter_for(edition, update_type: "republish")
    draft_publication_presenter = PublishingApiPresenters.presenter_for(draft_edition, update_type: "republish")
    html_attachment_presenter = PublishingApiPresenters.presenter_for(edition.attachments.first, update_type: "republish")
    draft_html_attachment_presenter = PublishingApiPresenters.presenter_for(draft_edition.attachments.first, update_type: "republish")

    WebMock.reset!

    requests = [
      stub_publishing_api_patch_links(publication_presenter.content_id, links: publication_presenter.links),
      stub_publishing_api_put_content(publication_presenter.content_id, with_locale(:en) { publication_presenter.content }),
      stub_publishing_api_put_content(publication_presenter.content_id, with_locale(:es) { publication_presenter.content }),
      stub_publishing_api_publish(publication_presenter.content_id, locale: "en", update_type: nil),
      stub_publishing_api_publish(publication_presenter.content_id, locale: "es", update_type: nil),
      stub_publishing_api_put_content(html_attachment_presenter.content_id, html_attachment_presenter.content),
      stub_publishing_api_patch_links(html_attachment_presenter.content_id, links: html_attachment_presenter.links),
      stub_publishing_api_publish(html_attachment_presenter.content_id, locale: "en", update_type: nil),
      stub_publishing_api_put_content(draft_publication_presenter.content_id, with_locale(:en) { draft_publication_presenter.content }),
      stub_publishing_api_put_content(draft_publication_presenter.content_id, with_locale(:es) { draft_publication_presenter.content }),
      stub_publishing_api_put_content(draft_html_attachment_presenter.content_id, draft_html_attachment_presenter.content),
    ]

    PublishingApiDocumentRepublishingWorker.new.perform(edition.document.id)

    assert_all_requested(requests)
  end

  test "Should only publish live edition when document is published with invalid draft" do
    edition = build(:published_publication)
    draft_edition = edition.create_draft(build(:user))
    draft_edition.title = nil
    draft_edition.save!(validate: false)

    publication_presenter = PublishingApiPresenters.presenter_for(edition, update_type: "republish")
    html_attachment_presenter = PublishingApiPresenters.presenter_for(edition.attachments.first, update_type: "republish")

    WebMock.reset!

    requests = [
      stub_publishing_api_patch_links(publication_presenter.content_id, links: publication_presenter.links),
      stub_publishing_api_put_content(publication_presenter.content_id, publication_presenter.content),
      stub_publishing_api_publish(publication_presenter.content_id, locale: "en", update_type: nil),
      stub_publishing_api_put_content(html_attachment_presenter.content_id, html_attachment_presenter.content),
      stub_publishing_api_patch_links(html_attachment_presenter.content_id, links: html_attachment_presenter.links),
      stub_publishing_api_publish(html_attachment_presenter.content_id, locale: "en", update_type: nil),
    ]

    PublishingApiDocumentRepublishingWorker.new.perform(edition.document.id)

    assert_all_requested(requests)
  end
  ###########################

  ### Unpublished documents ###
  test "Should unpublish the live edition with all locales when document is unpublished with no draft" do
    unpublishing = build(:unpublishing, redirect: false)
    edition = build(:unpublished_publication, unpublishing:)
    with_locale(:es) { edition.title = "spanish-title" }
    edition.save!

    publication_presenter = PublishingApiPresenters.presenter_for(edition, update_type: "republish")
    html_attachment_presenter = PublishingApiPresenters.presenter_for(edition.attachments.first, update_type: "republish")

    WebMock.reset!

    requests = [
      stub_publishing_api_unpublish(publication_presenter.content_id, body: {
        type: "gone",
        locale: "en",
        discard_drafts: true,
      }),
      stub_publishing_api_unpublish(publication_presenter.content_id, body: {
        type: "gone",
        locale: "es",
        discard_drafts: true,
      }),
      stub_publishing_api_put_content(html_attachment_presenter.content_id, html_attachment_presenter.content),
      stub_publishing_api_patch_links(html_attachment_presenter.content_id, links: html_attachment_presenter.links),
      stub_publishing_api_unpublish(html_attachment_presenter.content_id, body: {
        type: "redirect",
        alternative_path: edition.base_path,
        allow_draft: true,
        locale: "en",
      }),
    ]

    PublishingApiDocumentRepublishingWorker.new.perform(edition.document.id)

    assert_all_requested(requests)
  end

  test "Should unpublish live edition and update draft when document is unpublished with new draft" do
    unpublishing = build(:unpublishing, redirect: false)
    edition = build(:unpublished_publication, unpublishing:)
    with_locale(:es) { edition.title = "spanish-title" }
    edition.save!
    draft_edition = edition.create_draft(build(:user))
    draft_edition.change_note = "change-note"
    draft_edition.save!

    publication_presenter = PublishingApiPresenters.presenter_for(edition, update_type: "republish")
    draft_publication_presenter = PublishingApiPresenters.presenter_for(draft_edition, update_type: "republish")
    html_attachment_presenter = PublishingApiPresenters.presenter_for(edition.attachments.first, update_type: "republish")
    draft_html_attachment_presenter = PublishingApiPresenters.presenter_for(draft_edition.attachments.first, update_type: "republish")

    WebMock.reset!

    requests = [
      stub_publishing_api_unpublish(publication_presenter.content_id, body: {
        type: "gone",
        locale: "en",
        discard_drafts: true,
      }),
      stub_publishing_api_unpublish(publication_presenter.content_id, body: {
        type: "gone",
        locale: "es",
        discard_drafts: true,
      }),
      stub_publishing_api_put_content(html_attachment_presenter.content_id, html_attachment_presenter.content),
      stub_publishing_api_patch_links(html_attachment_presenter.content_id, links: html_attachment_presenter.links),
      stub_publishing_api_unpublish(html_attachment_presenter.content_id, body: {
        type: "redirect",
        alternative_path: edition.base_path,
        allow_draft: true,
        locale: "en",
      }),
      stub_publishing_api_put_content(draft_publication_presenter.content_id, with_locale(:en) { draft_publication_presenter.content }),
      stub_publishing_api_put_content(draft_publication_presenter.content_id, with_locale(:es) { draft_publication_presenter.content }),
      stub_publishing_api_put_content(draft_html_attachment_presenter.content_id, draft_html_attachment_presenter.content),
    ]

    PublishingApiDocumentRepublishingWorker.new.perform(edition.document.id)

    assert_all_requested(requests)
  end

  test "Should only unpublish live edition when document is unpublished with invalid draft" do
    unpublishing = build(:unpublishing, redirect: false)
    edition = build(:unpublished_publication, unpublishing:)
    draft_edition = edition.create_draft(build(:user))
    draft_edition.title = nil
    draft_edition.save!(validate: false)

    publication_presenter = PublishingApiPresenters.presenter_for(edition, update_type: "republish")
    html_attachment_presenter = PublishingApiPresenters.presenter_for(edition.attachments.first, update_type: "republish")

    WebMock.reset!

    requests = [
      stub_publishing_api_unpublish(publication_presenter.content_id, body: {
        type: "gone",
        locale: "en",
        discard_drafts: true,
      }),
      stub_publishing_api_put_content(html_attachment_presenter.content_id, html_attachment_presenter.content),
      stub_publishing_api_patch_links(html_attachment_presenter.content_id, links: html_attachment_presenter.links),
      stub_publishing_api_unpublish(html_attachment_presenter.content_id, body: {
        type: "redirect",
        alternative_path: edition.base_path,
        allow_draft: true,
        locale: "en",
      }),
    ]

    PublishingApiDocumentRepublishingWorker.new.perform(edition.document.id)

    assert_all_requested(requests)
  end
  ###########################

  ### Withdrawn documents ###
  test "Should publish and withdraw the live edition when document is withdrawn with no draft" do
    edition = build(:withdrawn_publication)
    with_locale(:es) { edition.title = "spanish-title" }
    edition.save!

    publication_presenter = PublishingApiPresenters.presenter_for(edition, update_type: "republish")
    html_attachment_presenter = PublishingApiPresenters.presenter_for(edition.attachments.first, update_type: "republish")
    withdrawal_content = {
      type: "withdrawal",
      explanation: Whitehall::GovspeakRenderer.new.govspeak_to_html(edition.unpublishing.explanation),
      unpublished_at: edition.unpublishing.unpublished_at.utc.iso8601,
    }

    WebMock.reset!

    requests = [
      stub_publishing_api_put_content(publication_presenter.content_id, with_locale(:en) { publication_presenter.content }),
      stub_publishing_api_put_content(publication_presenter.content_id, with_locale(:es) { publication_presenter.content }),
      stub_publishing_api_patch_links(publication_presenter.content_id, links: publication_presenter.links),
      stub_publishing_api_publish(publication_presenter.content_id, locale: "en", update_type: nil),
      stub_publishing_api_publish(publication_presenter.content_id, locale: "es", update_type: nil),
      stub_publishing_api_unpublish(publication_presenter.content_id, body: withdrawal_content.merge(locale: "en")),
      stub_publishing_api_unpublish(publication_presenter.content_id, body: withdrawal_content.merge(locale: "es")),
    ]
    repeated_requests = [
      stub_publishing_api_put_content(html_attachment_presenter.content_id, html_attachment_presenter.content),
      stub_publishing_api_patch_links(html_attachment_presenter.content_id, links: html_attachment_presenter.links),
      stub_publishing_api_publish(html_attachment_presenter.content_id, locale: "en", update_type: nil),
      stub_publishing_api_unpublish(html_attachment_presenter.content_id, body: withdrawal_content.merge(locale: "en")),
    ]

    PublishingApiDocumentRepublishingWorker.new.perform(edition.document.id)

    assert_all_requested(requests)
    repeated_requests.each { |request| assert_requested request, times: 2 }
  end
  ###########################
end
