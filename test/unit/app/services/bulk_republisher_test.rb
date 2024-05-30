require "test_helper"

class BulkRepublisherTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe "#republish_all_organisation_about_us_pages" do
    test "queues Organisation 'About us' pages for republishing" do
      queue_sequence = sequence("queue")

      2.times do
        about_us_page = create(:about_corporate_information_page)

        PublishingApiDocumentRepublishingWorker
          .expects(:perform_async_in_queue)
          .with("bulk_republishing", about_us_page.document_id, true)
          .in_sequence(queue_sequence)
      end

      BulkRepublisher.new.republish_all_organisation_about_us_pages
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
      document_without_pre_publication_edition = create(:document, editions: [build(:published_edition)])

      PublishingApiDocumentRepublishingWorker
        .expects(:perform_async_in_queue)
        .with("bulk_republishing", document_without_pre_publication_edition.id, true)
        .never

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
  end
end
