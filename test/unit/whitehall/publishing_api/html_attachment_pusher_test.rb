require 'test_helper'
require 'whitehall/publishing_api/html_attachment_pusher'

module Whitehall
  class PublishingApi
    class HtmlAttachmentPusherTest < ActiveSupport::TestCase
      def call(edition)
        event = self.class.name.demodulize.underscore
        HtmlAttachmentPusher.new(edition: edition, event: event).call
      end

      class Publish < HtmlAttachmentPusherTest
        test "for something that can't have html attachments" do
          Whitehall::PublishingApi.expects(:publish_async).never
          call(build(:person))
        end

        test "with no html attachments" do
          publication = create(:published_publication, :with_external_attachment)
          Whitehall::PublishingApi.expects(:publish_async).never
          call(publication)
        end

        test "with an html attachment on a new document" do
          publication = create(:published_publication)
          attachment = publication.html_attachments.first
          Whitehall::PublishingApi.expects(:publish_async).with(attachment)
          call(publication)
        end

        test "with an html attachment on all versions of a document" do
          publication = create(:published_publication)

          new_edition = publication.create_draft(create(:writer))
          new_edition.minor_change = true
          new_edition.submit!
          new_edition.publish!

          attachment = new_edition.html_attachments.first

          Whitehall::PublishingApi.expects(:publish_async).with(attachment)
          call(new_edition)
        end

        test "with an html attachment on the new version of a document" do
          publication = create(:published_publication, :with_external_attachment)

          new_edition = publication.create_draft(create(:writer))
          new_edition.attachments = [build(:html_attachment)]
          new_edition.minor_change = true
          new_edition.submit!
          new_edition.publish!

          attachment = new_edition.html_attachments.first

          Whitehall::PublishingApi.expects(:publish_async).with(attachment)
          call(new_edition)
        end

        test "with an html attachment on the old version of a document" do
          publication = create(:published_publication)

          new_edition = publication.create_draft(create(:writer))
          new_edition.attachments = [build(:external_attachment)]
          new_edition.minor_change = true
          new_edition.submit!
          new_edition.publish!

          Whitehall::PublishingApi.expects(:publish_async).never

          old_attachment = publication.html_attachments.first
          Whitehall::PublishingApi.expects(:publish_redirect_async).with(
            old_attachment.content_id,
            new_edition.search_link
          )

          call(new_edition)
        end

        test "with different html attachments on each version of a document" do
          publication = create(:published_publication)

          new_edition = publication.create_draft(create(:writer))
          new_edition.attachments = [build(:html_attachment)]
          new_edition.minor_change = true
          new_edition.submit!
          new_edition.publish!

          new_attachment = new_edition.html_attachments.first
          Whitehall::PublishingApi.expects(:publish_async).with(new_attachment)

          old_attachment = publication.html_attachments.first
          Whitehall::PublishingApi.expects(:publish_redirect_async).with(
            old_attachment.content_id,
            new_edition.search_link
          )

          call(new_edition)
        end
      end
    end
  end
end
