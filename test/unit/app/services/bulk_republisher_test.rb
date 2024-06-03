require "test_helper"

class BulkRepublisherTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe "#republish_all_published_organisation_about_us_pages" do
    test "queues all published organisation 'About us' pages for republishing" do
      queue_sequence = sequence("queue")

      2.times do
        about_us_page = create(:about_corporate_information_page)

        PublishingApiDocumentRepublishingWorker
          .expects(:perform_async_in_queue)
          .with("bulk_republishing", about_us_page.document_id, true)
          .in_sequence(queue_sequence)
      end

      BulkRepublisher.new.republish_all_published_organisation_about_us_pages
    end

    test "doesn't queue draft organisation 'About us' pages for republishing" do
      about_us_page = create(:draft_about_corporate_information_page)

      PublishingApiDocumentRepublishingWorker
        .expects(:perform_async_in_queue)
        .with("bulk_republishing", about_us_page.document_id, true)
        .never

      BulkRepublisher.new.republish_all_published_organisation_about_us_pages
    end
  end

  describe "#republish_all_documents" do
    test "queues all documents for republishing" do
      queue_sequence = sequence("queue")

      2.times do
        document = create(:document)

        PublishingApiDocumentRepublishingWorker
          .expects(:perform_async_in_queue)
          .with("bulk_republishing", document.id, true)
          .in_sequence(queue_sequence)
      end

      BulkRepublisher.new.republish_all_documents
    end
  end

  describe "#republish_all_documents_with_pre_publication_editions" do
    test "queues all documents with pre-publication editions for republishing" do
      queue_sequence = sequence("queue")

      2.times do
        document_with_pre_publication_edition = create(:document, editions: [build(:published_edition), build(:draft_edition)])

        PublishingApiDocumentRepublishingWorker
          .expects(:perform_async_in_queue)
          .with("bulk_republishing", document_with_pre_publication_edition.id, true)
          .in_sequence(queue_sequence)
      end

      BulkRepublisher.new.republish_all_documents_with_pre_publication_editions
    end

    test "doesn't queue documents without pre-publication editions for republishing" do
      document = create(:document, editions: [build(:published_edition)])

      PublishingApiDocumentRepublishingWorker
        .expects(:perform_async_in_queue)
        .with("bulk_republishing", document.id, true)
        .never

      BulkRepublisher.new.republish_all_documents_with_pre_publication_editions
    end
  end

  describe "#republish_all_documents_with_pre_publication_editions_with_html_attachments" do
    test "queues all documents with pre-publication editions with HTML attachments for republishing" do
      queue_sequence = sequence("queue")

      2.times do
        draft_edition = build(:draft_edition)
        document = create(:document, editions: [build(:published_edition), draft_edition])
        create(:html_attachment, attachable_type: "Edition", attachable_id: draft_edition.id)

        PublishingApiDocumentRepublishingWorker
          .expects(:perform_async_in_queue)
          .with("bulk_republishing", document.id, true)
          .in_sequence(queue_sequence)
      end

      BulkRepublisher.new.republish_all_documents_with_pre_publication_editions_with_html_attachments
    end

    test "doesn't queue documents for republishing if the editions with HTML attachments aren't pre-publication editions" do
      document = create(:document, editions: [build(:published_edition)])
      create(:html_attachment, attachable_type: "Edition", attachable_id: document.live_edition_id)

      PublishingApiDocumentRepublishingWorker
        .expects(:perform_async_in_queue)
        .with("bulk_republishing", document.id, true)
        .never

      BulkRepublisher.new.republish_all_documents_with_pre_publication_editions_with_html_attachments
    end

    test "doesn't queue documents republishing when there are pre-publication editions but none have HTML attachments" do
      document = create(:document, editions: [build(:published_edition), build(:draft_edition)])

      PublishingApiDocumentRepublishingWorker
        .expects(:perform_async_in_queue)
        .with("bulk_republishing", document.id, true)
        .never

      BulkRepublisher.new.republish_all_documents_with_pre_publication_editions_with_html_attachments
    end
  end
end
