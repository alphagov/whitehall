require 'test_helper'

module ServiceListeners
  class PublishingApiPusherTest < ActiveSupport::TestCase
    def stub_corporate_information_pages_pusher(edition, event)
      PublishingApiCorporateInformationPagesWorker
        .any_instance
        .expects(:perform)
        .with(edition.id, event)
    end

    def stub_html_attachment_pusher(edition, event)
      PublishingApiHtmlAttachmentsWorker
        .any_instance
        .expects(:perform)
        .with(edition.id, event)
    end

    def stub_publications_pusher(edition, event)
      PublishingApiPublicationsWorker
        .any_instance
        .expects(:perform)
        .with(edition.id, event)
    end

    test "saves draft async for update_draft" do
      edition = build(:draft_publication, document: build(:document))
      Whitehall::PublishingApi.expects(:save_draft_async).with(edition)
      stub_html_attachment_pusher(edition, "update_draft")
      stub_publications_pusher(edition, "update_draft")
      PublishingApiPusher.new(edition).push(event: "update_draft")
    end

    test "saves attachments draft" do
      edition = build(
        :draft_publication,
        html_attachments: [build(:html_attachment)],
        document: build(:document)
      )
      Whitehall::PublishingApi.expects(:save_draft_async).with(edition)
      stub_html_attachment_pusher(edition, "update_draft")
      stub_publications_pusher(edition, "update_draft")
      PublishingApiPusher.new(edition).push(event: "update_draft")
    end

    test "publish publishes" do
      edition = build(:publication, document: build(:document))
      Whitehall::PublishingApi.expects(:publish_async).with(edition)
      stub_html_attachment_pusher(edition, "publish")
      stub_publications_pusher(edition, "publish")
      PublishingApiPusher.new(edition).push(event: "publish")
    end

    test "force_publish publishes" do
      edition = build(:publication, document: build(:document))
      Whitehall::PublishingApi.expects(:publish_async).with(edition)
      stub_html_attachment_pusher(edition, "force_publish")
      stub_publications_pusher(edition, "force_publish")
      PublishingApiPusher.new(edition).push(event: "force_publish")
    end

    test "update_draft_translation saves draft translation" do
      edition = build(:publication, document: build(:document))
      Whitehall::PublishingApi.expects(:save_draft_translation_async).with(edition, 'en')
      stub_html_attachment_pusher(edition, "update_draft_translation")
      stub_publications_pusher(edition, "update_draft_translation")
      PublishingApiPusher.new(edition).push(event: "update_draft_translation", options: { locale: "en" })
    end

    test "withdraw republishes" do
      document = build(:document)
      edition = build(:publication, document: document)
      edition.build_unpublishing(explanation: 'Old information',
        unpublishing_reason_id: UnpublishingReason::Withdrawn.id)

      Whitehall::PublishingApi.expects(:publish_withdrawal_async)
        .with(edition.document.content_id, edition.unpublishing.explanation, edition.primary_locale)
      stub_html_attachment_pusher(edition, "withdraw")
      stub_publications_pusher(edition, "withdraw")

      PublishingApiPusher.new(edition).push(event: "withdraw")
    end

    test "unpublish publishes the unpublishing" do
      edition = create(:unpublished_publication)
      Whitehall::PublishingApi.expects(:unpublish_async).with(edition.unpublishing)
      stub_html_attachment_pusher(edition, "unpublish")
      stub_publications_pusher(edition, "unpublish")
      PublishingApiPusher.new(edition).push(event: "unpublish")
    end

    test "force_schedule schedules the edition" do
      edition = build(:publication, document: build(:document))
      Whitehall::PublishingApi.expects(:schedule_async).with(edition)
      stub_html_attachment_pusher(edition, "force_schedule")
      stub_publications_pusher(edition, "force_schedule")
      PublishingApiPusher.new(edition).push(event: "force_schedule")
    end

    test "schedule schedules the edition" do
      edition = build(:publication, document: build(:document))
      Whitehall::PublishingApi.expects(:schedule_async).with(edition)
      stub_html_attachment_pusher(edition, "schedule")
      stub_publications_pusher(edition, "schedule")
      PublishingApiPusher.new(edition).push(event: "schedule")
    end

    test "unschedule unschedules the edition" do
      edition = build(:publication, document: build(:document))
      Whitehall::PublishingApi.expects(:unschedule_async).with(edition)
      stub_html_attachment_pusher(edition, "unschedule")
      stub_publications_pusher(edition, "unschedule")
      PublishingApiPusher.new(edition).push(event: "unschedule")
    end

    test "delete discards draft" do
      edition = build(:publication, document: build(:document))
      Whitehall::PublishingApi.expects(:discard_draft_async).with(edition)
      stub_html_attachment_pusher(edition, "delete")
      stub_publications_pusher(edition, "delete")
      PublishingApiPusher.new(edition).push(event: "delete")
    end

    def draft_edition_with_deleted_translation(type)
      published_edition = create(type, document: build(:document), translated_into: %i[es fr])

      old_translations = published_edition.translations
      en = old_translations[0]
      es = old_translations[1]
      fr = old_translations[2]

      draft_edition = published_edition.create_draft(create(:writer))
      draft_edition.translations = [en, es]
      draft_edition.minor_change = true
      draft_edition.submit!

      {
        draft_edition: draft_edition,
        deleted_translation: fr
      }
    end

    test "makes deleted translations gone" do
      res = draft_edition_with_deleted_translation(:published_case_study)
      new_edition = res[:draft_edition]
      fr = res[:deleted_translation]

      Whitehall::PublishingApi.expects(:publish_async).with(new_edition)
      stub_html_attachment_pusher(new_edition, "publish")

      pusher = mock
      PublishingApiGoneWorker
        .expects(:new)
        .returns(pusher)

      expected_original_url = Whitehall::UrlMaker.new.public_document_url(new_edition)

      pusher.expects(:perform).with(
        new_edition.document.content_id,
        "",
        "This translation is no longer available. You can find the original version of this content at [#{expected_original_url}](#{expected_original_url})",
        fr.locale
      )

      PublishingApiPusher.new(new_edition).push(event: "publish")
    end

    test 'handles corporate information pages' do
      edition = build(:corporate_information_page, document: build(:document))

      stub_corporate_information_pages_pusher(edition, 'update_draft')
      stub_html_attachment_pusher(edition, 'update_draft')

      PublishingApiPusher.new(edition).push(event: 'update_draft')
    end

    test 'handles publications' do
      edition = build(:publication, document: build(:document))

      stub_publications_pusher(edition, 'update_draft')
      stub_html_attachment_pusher(edition, 'update_draft')

      PublishingApiPusher.new(edition).push(event: 'update_draft')
    end
  end
end
