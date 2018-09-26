require 'test_helper'

class PublishingApiHtmlAttachmentsWorkerTest < ActiveSupport::TestCase
  def call(edition)
    event = self.class.name.demodulize.underscore
    PublishingApiHtmlAttachmentsWorker.new.perform(edition.id, event)
  end

  class Publish < PublishingApiHtmlAttachmentsWorkerTest
    test "for something that can't have html attachments doesn't publish" do
      call(create(:published_news_article))
    end

    test "with no html attachments doesn't publish" do
      publication = create(:published_publication, :with_external_attachment)
      call(publication)
    end

    test "with an html attachment on a new document publishes the attachment" do
      publication = create(:published_publication)
      attachment = publication.html_attachments.first
      PublishingApiWorker.any_instance.expects(:perform).with(
        "HtmlAttachment",
        attachment.id,
        "major",
        "en"
      )
      call(publication)
    end

    test "with an html attachment on a new consultation outcome it publishes the attachment" do
      consultation = create(:consultation_with_outcome_html_attachment, :published)
      attachment = consultation.outcome.html_attachments.first

      PublishingApiWorker.any_instance.expects(:perform).with(
        "HtmlAttachment",
        attachment.id,
        "major",
        "en"
      ).once

      call(consultation)
    end

    test "with an html attachment on a new consultation public feedback it publishes the attachment" do
      consultation = create(:consultation_with_public_feedback_html_attachment, :published)
      attachment = consultation.public_feedback.html_attachments.first

      PublishingApiWorker.any_instance.expects(:perform).with(
        "HtmlAttachment",
        attachment.id,
        "major",
        "en"
      ).once

      call(consultation)
    end

    test "with an html attachment on all parts of a new consultation it publishes all the attachments" do
      outcome = create(:consultation_outcome, :with_html_attachment)
      public_feedback = create(:consultation_public_feedback, :with_html_attachment)

      consultation = create(:published_consultation, :with_html_attachment,
        outcome: outcome,
        public_feedback: public_feedback)

      attachments = [outcome, public_feedback, consultation].flat_map(&:html_attachments)

      attachments.each do |attachment|
        PublishingApiWorker.any_instance.expects(:perform).with(
          "HtmlAttachment",
          attachment.id,
          "major",
          "en"
        ).once
      end

      call(consultation)
    end

    test "with an html attachment on all versions of a document publishes the attachment" do
      publication = create(:published_publication)

      new_edition = publication.create_draft(create(:writer))
      new_edition.minor_change = true
      new_edition.submit!
      new_edition.publish!

      attachment = new_edition.html_attachments.first

      PublishingApiWorker.any_instance.expects(:perform).with(
        "HtmlAttachment",
        attachment.id,
        "minor",
        "en"
      )
      call(new_edition)
    end

    test "with an html attachment on the new version of a document publishes the attachment" do
      publication = create(:published_publication, :with_external_attachment)

      new_edition = publication.create_draft(create(:writer))
      new_edition.attachments = [build(:html_attachment)]
      new_edition.minor_change = true
      new_edition.submit!
      new_edition.publish!

      attachment = new_edition.html_attachments.first

      PublishingApiWorker.any_instance.expects(:perform).with(
        "HtmlAttachment",
        attachment.id,
        "minor",
        "en"
      )
      call(new_edition)
    end

    test "with an html attachment on the old version of a document redirects the attachment" do
      publication = create(:published_publication)

      new_edition = publication.create_draft(create(:writer))
      new_edition.attachments = [build(:external_attachment)]
      new_edition.minor_change = true
      new_edition.submit!
      new_edition.publish!

      old_attachment = publication.html_attachments.first
      PublishingApiRedirectWorker.any_instance.expects(:perform).with(
        old_attachment.content_id,
        new_edition.search_link,
        "en"
      )

      call(new_edition)
    end

    test "with different html attachments on each version of a document publishes the new attachment and redirects the old" do
      publication = create(:published_publication)

      new_edition = publication.create_draft(create(:writer))
      new_edition.attachments = [build(:html_attachment)]
      new_edition.minor_change = true
      new_edition.submit!
      new_edition.publish!

      new_attachment = new_edition.html_attachments.first
      PublishingApiWorker.any_instance.expects(:perform).with(
        "HtmlAttachment",
        new_attachment.id,
        "minor",
        "en"
      )

      old_attachment = publication.html_attachments.first
      PublishingApiRedirectWorker.any_instance.expects(:perform).with(
        old_attachment.content_id,
        new_edition.search_link,
        "en"
      )

      call(new_edition)
    end
  end

  class UpdateDraft < PublishingApiHtmlAttachmentsWorkerTest
    test "for something that can't have html attachments doesn't save draft" do
      call(create(:published_news_article))
    end

    test "with no html attachments doesn't save draft" do
      publication = create(:published_publication, :with_external_attachment)
      call(publication)
    end

    test "with an html attachment on a new document saves it as a draft" do
      publication = create(:draft_publication)
      attachment = publication.html_attachments.first
      Whitehall::PublishingApi.expects(:save_draft_translation).with(
        attachment,
        "en",
        "major"
      )
      call(publication)
    end

    test "with an html attachment on all versions of a document saves it as a draft" do
      publication = create(:published_publication)
      new_edition = publication.create_draft(create(:writer))

      attachment = new_edition.html_attachments.first
      Whitehall::PublishingApi.expects(:save_draft_translation).with(
        attachment,
        "en",
        "major"
      )

      call(new_edition)
    end

    test "with an html attachment on the old version of a document leaves the attachment alone" do
      publication = create(:published_publication)

      new_edition = publication.create_draft(create(:writer))
      new_edition.attachments = [build(:external_attachment)]

      call(new_edition)
    end

    test "with different html attachments on each version of a document saves the new attachment as a draft" do
      publication = create(:published_publication)

      new_edition = publication.create_draft(create(:writer))
      new_edition.attachments = [build(:html_attachment)]

      new_attachment = new_edition.html_attachments.first
      Whitehall::PublishingApi.expects(:save_draft_translation).with(
        new_attachment,
        "en",
        "major"
      )

      call(new_edition)
    end

    test "with a deleted html attachment removes the draft" do
      publication = create(:draft_publication)
      attachment = publication.html_attachments.first
      attachment.destroy

      PublishingApiDiscardDraftWorker.any_instance.expects(:perform).with(
        attachment.content_id,
        "en"
      )

      Sidekiq::Testing.inline! do
        call(publication)
      end
    end
  end

  class Unpublish < PublishingApiHtmlAttachmentsWorkerTest
    test "for something that can't have html attachments doesn't publish a redirect" do
      call(create(:published_news_article))
    end

    test "for a publication with no html attachments doesn't publish a redirect" do
      publication = create(:published_publication, :with_external_attachment)
      call(publication)
    end

    test "for a publication that has been consolidated publishes a redirect to the alternative url" do
      publication = create(:unpublished_publication_consolidated)
      attachment = publication.html_attachments.first
      PublishingApiRedirectWorker.any_instance.expects(:perform).with(
        attachment.content_id,
        "/government/another/page",
        "en",
        false
      )
      call(publication)
    end

    test "for a publication that has been unpublished with a redirect publishes a redirect to the alternative url" do
      publication = create(:unpublished_publication_in_error_redirect)
      attachment = publication.html_attachments.first
      PublishingApiRedirectWorker.any_instance.expects(:perform).with(
        attachment.content_id,
        "/government/another/page",
        "en",
        false
      )
      call(publication)
    end

    test "for a publication that has been unpublished without a redirect publishes a redirect to the parent document" do
      publication = create(:unpublished_publication_in_error_no_redirect)
      attachment = publication.html_attachments.first
      PublishingApiRedirectWorker.any_instance.expects(:perform).with(
        attachment.content_id,
        publication.search_link,
        "en",
        false
      )
      call(publication)
    end

    class Withdraw < PublishingApiHtmlAttachmentsWorkerTest
      test "for something that can't have html attachments doesn't publish a withdrawal" do
        call(create(:published_news_article))
      end

      test "for a publication with no html attachments doesn't publish a withdrawal" do
        publication = create(:withdrawn_publication, :with_external_attachment)
        call(publication)
      end

      test "for a publication that has been withdrawn publishes a withdrawal" do
        publication = create(:withdrawn_publication)
        attachment = publication.html_attachments.first
        PublishingApiWithdrawalWorker.any_instance.expects(:perform).with(
          attachment.content_id,
          "content was withdrawn",
          "en"
        )
        call(publication)
      end
    end

    class Delete < PublishingApiHtmlAttachmentsWorkerTest
      test "for something that can't have html attachments doesn't discard any drafts" do
        call(create(:published_news_article))
      end

      test "for a draft publication with no html attachments doesn't discard any drafts" do
        publication = create(:draft_publication, :with_external_attachment)
        call(publication)
      end

      test "for a draft publication with html attachments discards the draft" do
        publication = create(:draft_publication)
        attachment = publication.html_attachments.first
        PublishingApiDiscardDraftWorker.expects(:perform_async).with(
          attachment.content_id,
          "en"
        )
        call(publication)
      end

      test "for a draft publication with deleted html attachments discards the deleted attachment drafts" do
        publication = create(:draft_publication)
        attachment = publication.html_attachments.first
        attachment.destroy

        PublishingApiDiscardDraftWorker.expects(:perform_async).with(
          attachment.content_id,
          "en"
        )
        call(publication)
      end
    end
  end

  class Republish < PublishingApiHtmlAttachmentsWorkerTest
    test "for a draft publication with an attachment saves the draft" do
      publication = create(:draft_publication)
      attachment = publication.html_attachments.first
      Whitehall::PublishingApi.expects(:save_draft_translation).with(
        attachment,
        "en",
        "republish"
      )
      call(publication)
    end

    test "for a published publication with an attachment publishes the attachment" do
      publication = create(:published_publication)
      attachment = publication.html_attachments.first
      PublishingApiWorker.any_instance.expects(:perform).with(
        'HtmlAttachment',
        attachment.id,
        "republish",
        "en"
      )
      call(publication)
    end

    test "for a published publication with a deleted attachment discards the attachment draft" do
      publication = create(:published_publication)
      attachment = publication.html_attachments.first
      attachment.destroy
      PublishingApiDiscardDraftWorker.any_instance.expects(:perform).with(
        attachment.content_id,
        "en"
      )
      Sidekiq::Testing.inline! do
        call(publication)
      end
    end

    test "for a withdrawn publicaton with an attachment withdraws the attachment" do
      publication = create(:withdrawn_publication)
      attachment = publication.html_attachments.first
      PublishingApiWorker.any_instance.expects(:perform).with(
        'HtmlAttachment',
        attachment.id,
        "republish",
        "en"
      )
      PublishingApiWithdrawalWorker.any_instance.expects(:perform).with(
        attachment.content_id,
        "content was withdrawn",
        "en"
      )
      call(publication)
    end

    test "for a publication that has been consolidated publishes a redirect to the alternative url" do
      publication = create(:unpublished_publication_consolidated)
      attachment = publication.html_attachments.first
      Whitehall::PublishingApi.expects(:save_draft_translation).with(
        attachment,
        "en",
        "republish"
      )
      PublishingApiRedirectWorker.any_instance.expects(:perform).with(
        attachment.content_id,
        "/government/another/page",
        "en",
        true
      )
      call(publication)
    end

    test "for a publication that has been unpublished with a redirect publishes a redirect to the alternative url" do
      publication = create(:unpublished_publication_in_error_redirect)
      attachment = publication.html_attachments.first
      Whitehall::PublishingApi.expects(:save_draft_translation).with(
        attachment,
        "en",
        "republish"
      )
      PublishingApiRedirectWorker.any_instance.expects(:perform).with(
        attachment.content_id,
        "/government/another/page",
        "en",
        true
      )
      call(publication)
    end

    test "for a publication that has been unpublished without a redirect publishes a redirect to the parent document" do
      publication = create(:unpublished_publication_in_error_no_redirect)
      attachment = publication.html_attachments.first
      Whitehall::PublishingApi.expects(:save_draft_translation).with(
        attachment,
        "en",
        "republish"
      )
      PublishingApiRedirectWorker.any_instance.expects(:perform).with(
        attachment.content_id,
        publication.search_link,
        "en",
        true
      )
      call(publication)
    end
  end

  class Unwithdraw < PublishingApiHtmlAttachmentsWorkerTest
    test "with an html attachment on a new document publishes the attachment" do
      publication = create(:published_publication)
      attachment = publication.html_attachments.first
      PublishingApiWorker.any_instance.expects(:perform).with(
        "HtmlAttachment",
        attachment.id,
        "major",
        "en"
      )
      call(publication)
    end
  end
end
