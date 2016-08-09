require 'test_helper'

module ServiceListeners
  class PublishingApiPusherTest < ActiveSupport::TestCase
    test "saves draft async for update_draft" do
      edition = build(:draft_publication)
      Whitehall::PublishingApi.expects(:save_draft_async).with(edition)
      PublishingApiPusher.new(edition).push(event: "update_draft")
    end

    test "saves attachments draft" do
      edition = build(
        :draft_publication,
        html_attachments: [attachment = build(:html_attachment)]
      )
      Whitehall::PublishingApi.expects(:save_draft_async).with(edition)
      Whitehall::PublishingApi.expects(:save_draft_async).with(attachment)
      PublishingApiPusher.new(edition).push(event: "update_draft")
    end

    test "publish publishes" do
      edition = build(:publication)
      Whitehall::PublishingApi.expects(:publish_async).with(edition)
      PublishingApiPusher.new(edition).push(event: "publish")
    end

    test "publish publishes attachments" do
      edition = build(
        :publication,
        html_attachments: [attachment = build(:html_attachment)]
      )
      Whitehall::PublishingApi.expects(:publish_async).with(edition)
      Whitehall::PublishingApi.expects(:publish_async).with(attachment)
      PublishingApiPusher.new(edition).push(event: "publish")
    end

    test "force_publish publishes" do
      edition = build(:publication)
      Whitehall::PublishingApi.expects(:publish_async).with(edition)
      PublishingApiPusher.new(edition).push(event: "force_publish")
    end

    test "force_publish publishes attachments" do
      edition = build(
        :publication,
        html_attachments: [attachment = build(:html_attachment)]
      )
      Whitehall::PublishingApi.expects(:publish_async).with(edition)
      Whitehall::PublishingApi.expects(:publish_async).with(attachment)
      PublishingApiPusher.new(edition).push(event: "force_publish")
    end

    test "update_draft_translation saves draft translation" do
      edition = build(:publication)
      Whitehall::PublishingApi.expects(:save_draft_translation_async).with(edition, 'en')
      PublishingApiPusher.new(edition).push(event: "update_draft_translation", options: { locale: "en" })
    end

    test "update_draft_translation updates the attachments" do
      edition = build(
        :publication,
        html_attachments: [attachment = build(:html_attachment)]
      )
      Whitehall::PublishingApi.expects(:save_draft_translation_async).with(edition, 'en')
      Whitehall::PublishingApi.expects(:save_draft_translation_async).with(attachment, 'en')
      PublishingApiPusher.new(edition).push(event: "update_draft_translation", options: { locale: "en" })
    end

    test "withdraw republishes" do
      document = build(:document)
      edition = build(:publication, document: document)
      edition.build_unpublishing(explanation: 'Old information',
        unpublishing_reason_id: UnpublishingReason::Withdrawn.id)

      Whitehall::PublishingApi.expects(:publish_withdrawal_async)
        .with(edition.document.content_id, edition.unpublishing.explanation, edition.primary_locale)

      PublishingApiPusher.new(edition).push(event: "withdraw")
    end

    test "withdraw republishes the attachments" do
      document = build(:document)
      edition = build(
        :publication,
        html_attachments: [attachment = build(:html_attachment)],
        document: document,
      )
      edition.build_unpublishing(explanation: 'Old information',
        unpublishing_reason_id: UnpublishingReason::Withdrawn.id)

      Whitehall::PublishingApi.expects(:publish_withdrawal_async)
        .with(edition.content_id, edition.unpublishing.explanation, edition.primary_locale)

      Whitehall::PublishingApi.expects(:republish_async).with(attachment)

      PublishingApiPusher.new(edition).push(event: "withdraw")
    end

    test "unpublish publishes the unpublishing" do
      edition = create(:unpublished_publication)
      Whitehall::PublishingApi.expects(:unpublish_async).with(edition.unpublishing)
      PublishingApiPusher.new(edition).push(event: "unpublish")
    end

    test "unpublish redirects the attachments to the alternative_url if in
      error with redirect" do
      edition = create(
        :unpublished_publication_in_error_redirect,
      )
      attachment = edition.attachments.first
      Whitehall::PublishingApi.expects(:publish_redirect_async).with(
        attachment.content_id,
        Addressable::URI.parse(edition.unpublishing.alternative_url).path
      )
      PublishingApiPusher.new(edition).push(event: "unpublish")
    end

    test "unpublish redirects the attachments to the parent if in error
      and !redirect" do
      edition = create(
        :unpublished_publication_in_error_no_redirect
      )
      attachment = edition.attachments.first
      Whitehall::PublishingApi.expects(:publish_redirect_async).with(
        attachment.content_id,
        Whitehall.url_maker.public_document_path(edition),
      )
      PublishingApiPusher.new(edition).push(event: "unpublish")
    end

    test "unpublish redirects the attachments to the alternative_url if
      unpublished consolidated" do
      edition = create(
        :unpublished_publication_consolidated,
      )
      attachment = edition.attachments.first
      Whitehall::PublishingApi.expects(:publish_redirect_async).with(
        attachment.content_id,
        Addressable::URI.parse(
          edition.unpublishing.alternative_url
        ).path,
      )
      PublishingApiPusher.new(edition).push(event: "unpublish")
    end

    test "force_schedule schedules the edition" do
      edition = build(:publication)
      Whitehall::PublishingApi.expects(:schedule_async).with(edition)
      PublishingApiPusher.new(edition).push(event: "force_schedule")
    end

    test "schedule schedules the edition" do
      edition = build(:publication)
      Whitehall::PublishingApi.expects(:schedule_async).with(edition)
      PublishingApiPusher.new(edition).push(event: "schedule")
    end

    test "unschedule unschedules the edition" do
      edition = build(:publication)
      Whitehall::PublishingApi.expects(:unschedule_async).with(edition)
      PublishingApiPusher.new(edition).push(event: "unschedule")
    end

    test "delete discards draft" do
      edition = build(:publication)
      Whitehall::PublishingApi.expects(:discard_draft_async).with(edition)
      PublishingApiPusher.new(edition).push(event: "delete")
    end

    test "delete discards draft attachments" do
      edition = build(
        :publication,
        html_attachments: [attachment = build(:html_attachment)]
      )
      Whitehall::PublishingApi.expects(:discard_draft_async).with(edition)
      Whitehall::PublishingApi.expects(:discard_draft_async).with(attachment)
      PublishingApiPusher.new(edition).push(event: "delete")
    end

    test "does not raise an error if the edition has no html_attachments association" do
      edition = create(:published_document_collection)
      PublishingApiPusher.new(edition).push(event: "publish")
    end
  end
end
