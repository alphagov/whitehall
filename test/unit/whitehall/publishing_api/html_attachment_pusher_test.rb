require 'test_helper'
require 'whitehall/publishing_api/html_attachment_pusher'

module Whitehall
  class PublishingApi
    class HtmlAttachmentPusherTest < ActiveSupport::TestCase
      setup do
        # Assert we don't make calls other than those we specify in tests
        WebMock.reset!
      end

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

      class UpdateDraft < HtmlAttachmentPusherTest
        test "for something that can't have html attachments" do
          Whitehall::PublishingApi.expects(:save_draft_async).never
          call(build(:person))
        end

        test "with no html attachments" do
          publication = create(:published_publication, :with_external_attachment)
          Whitehall::PublishingApi.expects(:save_draft_async).never
          call(publication)
        end

        test "with an html attachment on a new document" do
          publication = create(:draft_publication)
          attachment = publication.html_attachments.first
          Whitehall::PublishingApi.expects(:save_draft_async).with(attachment)
          call(publication)
        end

        test "with an html attachment on all versions of a document" do
          publication = create(:published_publication)
          new_edition = publication.create_draft(create(:writer))

          attachment = new_edition.html_attachments.first
          Whitehall::PublishingApi.expects(:save_draft_async).with(attachment)

          call(new_edition)
        end

        test "with an html attachment on the old version of a document" do
          publication = create(:published_publication)

          new_edition = publication.create_draft(create(:writer))
          new_edition.attachments = [build(:external_attachment)]

          Whitehall::PublishingApi.expects(:save_draft_async).never

          call(new_edition)
        end

        test "with different html attachments on each version of a document" do
          publication = create(:published_publication)

          new_edition = publication.create_draft(create(:writer))
          new_edition.attachments = [build(:html_attachment)]

          new_attachment = new_edition.html_attachments.first
          Whitehall::PublishingApi.expects(:save_draft_async).with(new_attachment)

          call(new_edition)
        end
      end

      class Unpublish < HtmlAttachmentPusherTest
        test "for something that can't have html attachments" do
          Whitehall::PublishingApi.expects(:publish_redirect_async).never
          call(build(:person))
        end

        test "for a publication with no html attachments" do
          publication = create(:published_publication, :with_external_attachment)
          Whitehall::PublishingApi.expects(:publish_redirect_async).never
          call(publication)
        end

        test "for a publication that has been consolidated" do
          publication = create(:unpublished_publication_consolidated)
          attachment = publication.html_attachments.first
          Whitehall::PublishingApi.expects(:publish_redirect_async).with(
            attachment.content_id,
            '/government/another/page'
          )
          call(publication)
        end

        test "for a publication that has been unpublished with a redirect" do
          publication = create(:unpublished_publication_in_error_redirect)
          attachment = publication.html_attachments.first
          Whitehall::PublishingApi.expects(:publish_redirect_async).with(
            attachment.content_id,
            '/government/another/page'
          )
          call(publication)
        end

        test "for a publication that has been unpublished without a redirect" do
          publication = create(:unpublished_publication_in_error_no_redirect)
          attachment = publication.html_attachments.first
          Whitehall::PublishingApi.expects(:publish_redirect_async).with(
            attachment.content_id,
            publication.search_link
          )
          call(publication)
        end

        class Withdraw < HtmlAttachmentPusherTest
          test "for something that can't have html attachments" do
            Whitehall::PublishingApi.expects(:publish_withdrawal_async).never
            call(build(:person))
          end

          test "for a publication with no html attachments" do
            publication = create(:withdrawn_publication, :with_external_attachment)
            Whitehall::PublishingApi.expects(:publish_withdrawal_async).never
            call(publication)
          end

          test "for a publication that has been withdrawn" do
            publication = create(:withdrawn_publication)
            attachment = publication.html_attachments.first
            Whitehall::PublishingApi.expects(:publish_withdrawal_async).with(
              attachment.content_id,
              "content was withdrawn",
              "en"
            )
            call(publication)
          end
        end
      end
    end
  end
end
