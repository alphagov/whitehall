require "test_helper"

module ServiceListeners
  class PublishingApiAssociatedDocumentsTest < ActiveSupport::TestCase
    def call(edition)
      event = self.class.name.demodulize.underscore
      PublishingApiAssociatedDocuments.process(edition, event)
    end

    class Publish < PublishingApiAssociatedDocumentsTest
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
          "en",
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
          "en",
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
          "en",
        ).once

        call(consultation)
      end

      test "with an html attachment on all parts of a new consultation it publishes all the attachments" do
        outcome = create(:consultation_outcome, :with_html_attachment)
        public_feedback = create(:consultation_public_feedback, :with_html_attachment)

        consultation = create(
          :published_consultation,
          :with_html_attachment,
          outcome:,
          public_feedback:,
        )

        attachments = [outcome, public_feedback, consultation].flat_map(&:html_attachments)

        attachments.each do |attachment|
          PublishingApiWorker.any_instance.expects(:perform).with(
            "HtmlAttachment",
            attachment.id,
            "major",
            "en",
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
          "en",
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
          "en",
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
          "en",
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
          "en",
        )

        old_attachment = publication.html_attachments.first
        PublishingApiRedirectWorker.any_instance.expects(:perform).with(
          old_attachment.content_id,
          new_edition.search_link,
          "en",
        )

        call(new_edition)
      end

      test "with deleted html attachments it redirects these to the new edition" do
        publication = create(:published_publication)

        deleted_attachment = create(:html_attachment)
        new_attachment = build(:html_attachment)

        edition = publication.create_draft(create(:writer))
        edition.attachments = [deleted_attachment]
        edition.minor_change = true
        edition.submit!
        edition.publish!

        new_edition = publication.create_draft(create(:writer))
        deleted_attachment.destroy!
        new_edition.attachments = [deleted_attachment, new_attachment]
        new_edition.minor_change = true

        new_edition.submit!
        new_edition.publish!

        PublishingApiWorker.any_instance.expects(:perform).with(
          "HtmlAttachment",
          new_attachment.id,
          "minor",
          "en",
        )

        PublishingApiRedirectWorker.any_instance.expects(:perform).with(
          deleted_attachment.content_id,
          new_edition.search_link,
          "en",
        )

        call(new_edition)
      end

      test "with a page with a translation both the page and its translation are published" do
        worldwide_organisation = create(:editionable_worldwide_organisation, :with_translated_page, translated_into: :fr)
        page = worldwide_organisation.pages.first

        PublishingApiWorker.any_instance.expects(:perform).with(
          "WorldwideOrganisationPage",
          page.id,
          "major",
          "en",
        )

        PublishingApiWorker.any_instance.expects(:perform).with(
          "WorldwideOrganisationPage",
          page.id,
          "major",
          "fr",
        )

        call(worldwide_organisation)
      end

      test "with an office on a new editionable worldwide organisation publishes the office, it's contact and it's page" do
        worldwide_organisation = create(:editionable_worldwide_organisation, :with_main_office, :with_page)

        PublishingApiWorker.any_instance.expects(:perform).with(
          "WorldwideOffice",
          worldwide_organisation.main_office.id,
          "major",
          "en",
        )

        PublishingApiWorker.any_instance.expects(:perform).with(
          "Contact",
          worldwide_organisation.main_office.contact.id,
          "major",
          "en",
        )

        PublishingApiWorker.any_instance.expects(:perform).with(
          "WorldwideOrganisationPage",
          worldwide_organisation.pages.first.id,
          "major",
          "en",
        )

        call(worldwide_organisation)
      end

      test "with an office on the old version of an editionable worldwide organisation redirects the office" do
        worldwide_organisation = create(:published_editionable_worldwide_organisation, :with_main_office)

        new_edition = worldwide_organisation.create_draft(create(:writer))
        new_edition.main_office.destroy!
        new_edition.minor_change = true
        new_edition.submit!
        new_edition.publish!

        old_office = worldwide_organisation.main_office

        PublishingApiRedirectWorker.any_instance.expects(:perform).with(
          old_office.content_id,
          new_edition.search_link,
          "en",
        )

        PublishingApiRedirectWorker.any_instance.expects(:perform).with(
          old_office.contact.content_id,
          new_edition.search_link,
          "en",
        )

        call(new_edition)
      end

      test "with a contact on the old version that remains on the new version of an editionable worldwide organisation it does not publish gone for the contact" do
        worldwide_organisation = create(:published_editionable_worldwide_organisation, :with_main_office)

        new_edition = worldwide_organisation.create_draft(create(:writer))
        new_edition.minor_change = true
        new_edition.submit!
        new_edition.publish!

        old_office = worldwide_organisation.main_office

        PublishingApiGoneWorker.any_instance.expects(:perform).with(
          old_office.contact.content_id,
          nil,
          nil,
          "en",
        ).never

        call(new_edition)
      end

      test "with a page on the old version of an editionable worldwide organisation redirects the page" do
        worldwide_organisation = create(:published_editionable_worldwide_organisation, :with_page)

        new_edition = worldwide_organisation.create_draft(create(:writer))
        new_edition.reload.pages.first.destroy!
        new_edition.minor_change = true
        new_edition.submit!
        new_edition.publish!

        old_page = worldwide_organisation.pages.first

        PublishingApiRedirectWorker.any_instance.expects(:perform).with(
          old_page.content_id,
          new_edition.search_link,
          "en",
        )

        call(new_edition)
      end
    end

    class UpdateDraft < PublishingApiAssociatedDocumentsTest
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
        Whitehall::PublishingApi.expects(:save_draft).with(
          attachment,
          "major",
        ).once
        call(publication)
      end

      test "with an html attachment on all versions of a document saves it as a draft" do
        publication = create(:published_publication)
        new_edition = publication.create_draft(create(:writer))

        attachment = new_edition.html_attachments.first
        Whitehall::PublishingApi.expects(:save_draft).with(
          attachment,
          "major",
        ).once

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
        Whitehall::PublishingApi.expects(:save_draft).with(
          new_attachment,
          "major",
        ).once

        call(new_edition)
      end

      test "with a deleted html attachment removes the draft" do
        publication = create(:draft_publication)
        attachment = publication.html_attachments.first
        attachment.destroy!

        PublishingApiDiscardDraftWorker.any_instance.expects(:perform).with(
          attachment.content_id,
          "en",
        )

        Sidekiq::Testing.inline! do
          call(publication)
        end
      end

      test "with an office on a new editionable worldwide organisation saves the office as draft" do
        worldwide_organisation = create(:editionable_worldwide_organisation, :with_main_office)

        Whitehall::PublishingApi.expects(:save_draft).with(
          worldwide_organisation.main_office,
          "major",
        ).once

        Whitehall::PublishingApi.expects(:save_draft).with(
          worldwide_organisation.main_office.contact,
          "major",
        ).once

        call(worldwide_organisation)
      end
    end

    class Unpublish < PublishingApiAssociatedDocumentsTest
      test "for something that can't have html attachments doesn't publish a redirect" do
        edition = create(:unpublished_edition)
        assert_equal edition.attachments.count, 0
        call(edition)
      end

      test "for a publication that has been consolidated publishes a redirect to the alternative url" do
        publication = create(:unpublished_publication_consolidated)
        attachment = publication.html_attachments.first
        PublishingApiRedirectWorker.any_instance.expects(:perform).with(
          attachment.content_id,
          "/government/another/page",
          "en",
          false,
        )
        call(publication)
      end

      test "for an editionable worldwide organisation that has been unpublished publishes a redirect to the alternative url for all the page translations" do
        worldwide_organisation = create(:unpublished_editionable_worldwide_organisation, :with_translated_page, translated_into: :fr)
        page = worldwide_organisation.pages.first

        PublishingApiRedirectWorker.any_instance.expects(:perform).with(
          page.content_id,
          "/world/organisations/editionable-worldwide-organisation-title",
          "en",
          false,
        )

        PublishingApiRedirectWorker.any_instance.expects(:perform).with(
          page.content_id,
          "/world/organisations/editionable-worldwide-organisation-title",
          "fr",
          false,
        )

        call(worldwide_organisation)
      end

      test "for an editionable worldwide organisation that has been consolidated publishes a redirect to the alternative url" do
        worldwide_organisation = create(:unpublished_editionable_worldwide_organisation_consolidated, :with_main_office, :with_page)
        office = worldwide_organisation.main_office
        page = worldwide_organisation.pages.first

        PublishingApiRedirectWorker.any_instance.expects(:perform).with(
          office.content_id,
          "/government/another/page",
          "en",
          false,
        )

        PublishingApiRedirectWorker.any_instance.expects(:perform).with(
          office.contact.content_id,
          "/government/another/page",
          "en",
          false,
        )

        PublishingApiRedirectWorker.any_instance.expects(:perform).with(
          page.content_id,
          "/government/another/page",
          "en",
          false,
        )

        call(worldwide_organisation)
      end

      test "for a publication that has been unpublished with a redirect publishes a redirect to the alternative url" do
        publication = create(:unpublished_publication_in_error_redirect)
        attachment = publication.html_attachments.first
        PublishingApiRedirectWorker.any_instance.expects(:perform).with(
          attachment.content_id,
          "/government/another/page",
          "en",
          false,
        )
        call(publication)
      end

      test "for an editionable worldwide organisation that has been unpublished with a redirect publishes a redirect to the alternative url" do
        worldwide_organisation = create(:unpublished_editionable_worldwide_organisation_in_error_redirect, :with_main_office)
        office = worldwide_organisation.main_office

        PublishingApiRedirectWorker.any_instance.expects(:perform).with(
          office.content_id,
          "/government/another/page",
          "en",
          false,
        )

        PublishingApiRedirectWorker.any_instance.expects(:perform).with(
          office.contact.content_id,
          "/government/another/page",
          "en",
          false,
        )

        call(worldwide_organisation)
      end

      test "for a publication that has been unpublished with an external redirect publishes a redirect to the alternative url" do
        external_url = "https://test.ukri.org/some-page"
        publication = create(:unpublished_publication, { unpublishing: build(:unpublishing, { redirect: true, alternative_url: external_url }) })
        attachment = publication.html_attachments.first
        PublishingApiRedirectWorker.any_instance.expects(:perform).with(
          attachment.content_id,
          external_url,
          "en",
          false,
        )
        call(publication)
      end

      test "for an editionable worldwide organisation that has been unpublished with an external redirect publishes a redirect to the alternative url" do
        external_url = "https://test.ukri.org/some-page"
        worldwide_organisation = create(:unpublished_editionable_worldwide_organisation_in_error_redirect, :with_main_office, :with_page, { unpublishing: build(:unpublishing, { redirect: true, alternative_url: external_url }) })
        office = worldwide_organisation.main_office
        page = worldwide_organisation.pages.first

        PublishingApiRedirectWorker.any_instance.expects(:perform).with(
          office.content_id,
          external_url,
          "en",
          false,
        )

        PublishingApiRedirectWorker.any_instance.expects(:perform).with(
          office.contact.content_id,
          external_url,
          "en",
          false,
        )

        PublishingApiRedirectWorker.any_instance.expects(:perform).with(
          page.content_id,
          external_url,
          "en",
          false,
        )

        call(worldwide_organisation)
      end

      test "for a publication that has been unpublished without a redirect publishes a redirect to the parent document" do
        publication = create(:unpublished_publication_in_error_no_redirect)
        attachment = publication.html_attachments.first
        PublishingApiRedirectWorker.any_instance.expects(:perform).with(
          attachment.content_id,
          publication.search_link,
          "en",
          false,
        )
        call(publication)
      end

      test "for an editionable worldwide organisation that has been unpublished without a redirect publishes a redirect to the parent docuemnt" do
        worldwide_organisation = create(:unpublished_editionable_worldwide_organisation_in_error_no_redirect, :with_main_office, :with_page)
        office = worldwide_organisation.main_office
        page = worldwide_organisation.pages.first

        PublishingApiRedirectWorker.any_instance.expects(:perform).with(
          office.content_id,
          worldwide_organisation.search_link,
          "en",
          false,
        )

        PublishingApiRedirectWorker.any_instance.expects(:perform).with(
          office.contact.content_id,
          worldwide_organisation.search_link,
          "en",
          false,
        )

        PublishingApiRedirectWorker.any_instance.expects(:perform).with(
          page.content_id,
          worldwide_organisation.search_link,
          "en",
          false,
        )

        call(worldwide_organisation)
      end

      class Withdraw < PublishingApiAssociatedDocumentsTest
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
            "en",
            false,
            publication.unpublishing.unpublished_at.to_s,
          )
          call(publication)
        end

        test "for an editionable worldwide organisation that has been withdrawn publishes a withdrawal for the office and page" do
          worldwide_organisation = create(:withdrawn_editionable_worldwide_organisation, :with_main_office, :with_page)
          page = worldwide_organisation.pages.first

          PublishingApiWithdrawalWorker.any_instance.expects(:perform).with(
            worldwide_organisation.main_office.content_id,
            "content was withdrawn",
            "en",
            false,
            worldwide_organisation.unpublishing.unpublished_at.to_s,
          )

          PublishingApiWithdrawalWorker.any_instance.expects(:perform).with(
            worldwide_organisation.main_office.contact.content_id,
            "content was withdrawn",
            "en",
            false,
            worldwide_organisation.unpublishing.unpublished_at.to_s,
          )

          PublishingApiWithdrawalWorker.any_instance.expects(:perform).with(
            page.content_id,
            "content was withdrawn",
            "en",
            false,
            worldwide_organisation.unpublishing.unpublished_at.to_s,
          )

          call(worldwide_organisation)
        end

        test "for a translated editionable worldwide organisation that has been withdrawn publishes a withdrawal for pages in all languages" do
          worldwide_organisation = create(:withdrawn_editionable_worldwide_organisation, :with_translated_page, translated_into: :fr)
          page = worldwide_organisation.pages.first

          PublishingApiWithdrawalWorker.any_instance.expects(:perform).with(
            page.content_id,
            "content was withdrawn",
            "en",
            false,
            worldwide_organisation.unpublishing.unpublished_at.to_s,
          )

          PublishingApiWithdrawalWorker.any_instance.expects(:perform).with(
            page.content_id,
            "content was withdrawn",
            "fr",
            false,
            worldwide_organisation.unpublishing.unpublished_at.to_s,
          )

          call(worldwide_organisation)
        end

        test "for a publication with a translated HTML attachment publishes a withdrawal with the expected locale for each attachment" do
          en_attachment = build(:html_attachment)
          cy_attachment = build(:html_attachment, locale: "cy")
          attachments = [en_attachment, cy_attachment]
          publication = create(:withdrawn_publication, attachments:)

          attachments.each do |attachment|
            PublishingApiWithdrawalWorker.any_instance.expects(:perform).with(
              attachment.content_id,
              "content was withdrawn",
              attachment.locale || I18n.default_locale.to_s,
              false,
              publication.unpublishing.unpublished_at.to_s,
            )
          end
          call(publication)
        end
      end

      class Delete < PublishingApiAssociatedDocumentsTest
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
            "en",
          )
          call(publication)
        end

        test "for a draft editionable worldwide organisation with offices and pages discards the draft" do
          worldwide_organisation = create(:draft_editionable_worldwide_organisation, :with_main_office, :with_page)

          PublishingApiDiscardDraftWorker.expects(:perform_async).with(
            worldwide_organisation.main_office.content_id,
            "en",
          )

          PublishingApiDiscardDraftWorker.expects(:perform_async).with(
            worldwide_organisation.main_office.contact.content_id,
            "en",
          )

          PublishingApiDiscardDraftWorker.expects(:perform_async).with(
            worldwide_organisation.pages.first.content_id,
            "en",
          )

          call(worldwide_organisation)
        end

        test "for a draft editionable worldwide organisation with pages in multiple languages discards the drafts for all languages" do
          worldwide_organisation = create(:draft_editionable_worldwide_organisation, :with_translated_page, translated_into: :fr)
          page = worldwide_organisation.pages.first

          PublishingApiDiscardDraftWorker.expects(:perform_async).with(
            page.content_id,
            "en",
          )

          PublishingApiDiscardDraftWorker.expects(:perform_async).with(
            page.content_id,
            "fr",
          )

          call(worldwide_organisation)
        end

        test "for a draft publication with deleted html attachments discards the deleted attachment drafts" do
          publication = create(:draft_publication)
          attachment = publication.html_attachments.first
          attachment.destroy!

          PublishingApiDiscardDraftWorker.expects(:perform_async).with(
            attachment.content_id,
            "en",
          )
          call(publication)
        end
      end
    end

    class Republish < PublishingApiAssociatedDocumentsTest
      test "for a draft publication with an attachment saves the draft" do
        publication = create(:draft_publication)
        attachment = publication.html_attachments.first
        Whitehall::PublishingApi.expects(:save_draft).with(
          attachment,
          "republish",
        ).once
        call(publication)
      end

      test "for a draft editionable worldwide organisation with an office and page publishes the draft office and page" do
        worldwide_organisation = create(:draft_editionable_worldwide_organisation, :with_main_office, :with_page)

        Whitehall::PublishingApi.expects(:save_draft).with(
          worldwide_organisation.main_office,
          "republish",
        ).once

        Whitehall::PublishingApi.expects(:save_draft).with(
          worldwide_organisation.main_office.contact,
          "republish",
        ).once

        Whitehall::PublishingApi.expects(:save_draft).with(
          worldwide_organisation.pages.first,
          "republish",
        ).once

        call(worldwide_organisation)
      end

      test "for a published publication with an attachment publishes the attachment" do
        publication = create(:published_publication)
        attachment = publication.html_attachments.first
        PublishingApiWorker.any_instance.expects(:perform).with(
          "HtmlAttachment",
          attachment.id,
          "republish",
          "en",
        )
        call(publication)
      end

      test "for a published editionable worldwide organisation with an office and page publishes the office and page" do
        worldwide_organisation = create(:published_editionable_worldwide_organisation, :with_main_office, :with_page)

        PublishingApiWorker.any_instance.expects(:perform).with(
          "WorldwideOffice",
          worldwide_organisation.main_office.id,
          "republish",
          "en",
        )

        PublishingApiWorker.any_instance.expects(:perform).with(
          "Contact",
          worldwide_organisation.main_office.contact.id,
          "republish",
          "en",
        )

        PublishingApiWorker.any_instance.expects(:perform).with(
          "WorldwideOrganisationPage",
          worldwide_organisation.pages.first.id,
          "republish",
          "en",
        )

        call(worldwide_organisation)
      end

      test "for a published publication with a deleted attachment discards the attachment draft" do
        publication = create(:published_publication)
        attachment = publication.html_attachments.first
        attachment.destroy!
        PublishingApiDiscardDraftWorker.any_instance.expects(:perform).with(
          attachment.content_id,
          "en",
        )
        Sidekiq::Testing.inline! do
          call(publication)
        end
      end

      test "for a withdrawn publication with an attachment withdraws the attachment" do
        publication = create(:withdrawn_publication)
        attachment = publication.html_attachments.first
        PublishingApiWorker.any_instance.expects(:perform).with(
          "HtmlAttachment",
          attachment.id,
          "republish",
          "en",
        )
        PublishingApiWithdrawalWorker.any_instance.expects(:perform).with(
          attachment.content_id,
          "content was withdrawn",
          "en",
          false,
          publication.unpublishing.unpublished_at.to_s,
        )
        call(publication)
      end

      test "for a publication that has been consolidated publishes a redirect to the alternative url" do
        publication = create(:unpublished_publication_consolidated)
        attachment = publication.html_attachments.first
        PublishingApiRedirectWorker.any_instance.expects(:perform).with(
          attachment.content_id,
          "/government/another/page",
          "en",
          true,
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
          true,
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
          true,
        )
        call(publication)
      end

      test "for a publication that has been unpublished does not publish the attachment in order to unpublish again" do
        publication = create(:unpublished_publication_in_error_no_redirect)
        PublishingApiWorker.any_instance.expects(:perform).never
        call(publication)
      end
    end

    class Unwithdraw < PublishingApiAssociatedDocumentsTest
      test "with an html attachment on a new document publishes the attachment" do
        publication = create(:published_publication)
        attachment = publication.html_attachments.first
        PublishingApiWorker.any_instance.expects(:perform).with(
          "HtmlAttachment",
          attachment.id,
          "major",
          "en",
        )
        call(publication)
      end
    end
  end
end
