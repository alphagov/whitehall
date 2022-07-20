require "test_helper"

module ServiceListeners
  class PublishingApiPusherTest < ActiveSupport::TestCase
    def stub_html_attachment_pusher(edition, event)
      PublishingApiHtmlAttachments
        .expects(:process)
        .with(edition, event)
    end

    test "saves draft async for update_draft" do
      edition = build(:draft_publication, document: build(:document))
      Whitehall::PublishingApi.expects(:save_draft).with(edition)
      stub_html_attachment_pusher(edition, "update_draft")
      Sidekiq::Testing.inline! do
        PublishingApiPusher.new(edition).push(event: "update_draft")
      end
    end

    test "saves attachments draft" do
      edition = build(
        :draft_publication,
        html_attachments: [build(:html_attachment)],
        document: build(:document),
      )
      Whitehall::PublishingApi.expects(:save_draft).with(edition)
      stub_html_attachment_pusher(edition, "update_draft")
      Sidekiq::Testing.inline! do
        PublishingApiPusher.new(edition).push(event: "update_draft")
      end
    end

    test "publish publishes" do
      edition = build(:publication, document: build(:document))
      Whitehall::PublishingApi.expects(:publish).with(edition)
      stub_html_attachment_pusher(edition, "publish")
      Sidekiq::Testing.inline! do
        PublishingApiPusher.new(edition).push(event: "publish")
      end
    end

    test "force_publish publishes" do
      edition = build(:publication, document: build(:document))
      Whitehall::PublishingApi.expects(:publish).with(edition)
      stub_html_attachment_pusher(edition, "force_publish")
      Sidekiq::Testing.inline! do
        PublishingApiPusher.new(edition).push(event: "force_publish")
      end
    end

    test "update_draft_translation saves draft translation" do
      edition = build(:publication, document: build(:document))
      Whitehall::PublishingApi.expects(:save_draft_translation).with(edition, "en")
      stub_html_attachment_pusher(edition, "update_draft_translation")
      Sidekiq::Testing.inline! do
        PublishingApiPusher.new(edition).push(event: "update_draft_translation", options: { locale: "en" })
      end
    end

    test "withdraw republishes for all translations" do
      translations = %i[es fr]
      document = build(:document)
      edition = create(:publication, document: document, translated_into: translations)
      edition.build_unpublishing(
        explanation: "Old information",
        unpublishing_reason_id: UnpublishingReason::Withdrawn.id,
      )

      Whitehall::PublishingApi.expects(:publish_withdrawal_async)
        .with(edition.document.content_id, edition.unpublishing.explanation, edition.unpublishing.unpublished_at, edition.primary_locale)

      translations.each do |translation|
        Whitehall::PublishingApi.expects(:publish_withdrawal_async)
          .with(edition.document.content_id, edition.unpublishing.explanation, edition.unpublishing.unpublished_at, translation.to_s)
      end

      stub_html_attachment_pusher(edition, "withdraw")

      Sidekiq::Testing.inline! do
        PublishingApiPusher.new(edition).push(event: "withdraw")
      end
    end

    test "unpublish publishes the unpublishing" do
      edition = create(:unpublished_publication)
      Whitehall::PublishingApi.expects(:unpublish_async).with(edition.unpublishing)
      stub_html_attachment_pusher(edition, "unpublish")
      Sidekiq::Testing.inline! do
        PublishingApiPusher.new(edition).push(event: "unpublish")
      end
    end

    test "force_schedule schedules the edition" do
      edition = build(:publication, document: build(:document))
      Whitehall::PublishingApi.expects(:schedule_async).with(edition)
      stub_html_attachment_pusher(edition, "force_schedule")
      Sidekiq::Testing.inline! do
        PublishingApiPusher.new(edition).push(event: "force_schedule")
      end
    end

    test "schedule schedules the edition" do
      edition = build(:publication, document: build(:document))
      Whitehall::PublishingApi.expects(:schedule_async).with(edition)
      stub_html_attachment_pusher(edition, "schedule")
      Sidekiq::Testing.inline! do
        PublishingApiPusher.new(edition).push(event: "schedule")
      end
    end

    test "unschedule unschedules the edition" do
      edition = build(:publication, document: build(:document))
      Whitehall::PublishingApi.expects(:unschedule_async).with(edition)
      stub_html_attachment_pusher(edition, "unschedule")
      Sidekiq::Testing.inline! do
        PublishingApiPusher.new(edition).push(event: "unschedule")
      end
    end

    test "delete discards draft" do
      edition = build(:publication, document: build(:document))
      Whitehall::PublishingApi.expects(:discard_draft_async).with(edition)
      stub_html_attachment_pusher(edition, "delete")
      Sidekiq::Testing.inline! do
        PublishingApiPusher.new(edition).push(event: "delete")
      end
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
        deleted_translation: fr,
      }
    end

    test "makes deleted translations gone" do
      res = draft_edition_with_deleted_translation(:published_case_study)
      new_edition = res[:draft_edition]
      fr = res[:deleted_translation]

      Whitehall::PublishingApi.expects(:publish).with(new_edition)

      pusher = mock
      PublishingApiGoneWorker
        .expects(:new)
        .returns(pusher)

      expected_original_url = Whitehall::UrlMaker.new.public_document_url(new_edition)

      pusher.expects(:perform).with(
        new_edition.document.content_id,
        "",
        "This translation is no longer available. You can find the original version of this content at [#{expected_original_url}](#{expected_original_url})",
        fr.locale,
      )

      Sidekiq::Testing.inline! do
        PublishingApiPusher.new(new_edition).push(event: "publish")
      end
    end

    test "handles corporate information pages" do
      edition = build(:corporate_information_page, document: build(:document))

      Whitehall::PublishingApi
        .expects(:save_draft_translation)
        .with(edition, :en, nil, bulk_publishing: false)

      PublishingApiPusher.new(edition).push(event: "update_draft")
    end

    test "handles publications" do
      edition = build(:publication, document: build(:document))

      Whitehall::PublishingApi
        .expects(:save_draft_translation)
        .with(edition, :en, nil, bulk_publishing: false)

      PublishingApiPusher.new(edition).push(event: "update_draft")
    end

    test "raises an error if an edition's document is locked" do
      document = build(:document, locked: true)
      edition = build(:edition, document: document)

      assert_raises LockedDocumentConcern::LockedDocumentError, "Cannot perform this operation on a locked document" do
        PublishingApiPusher.new(edition).push(event: "anything")
      end
    end
  end
end
