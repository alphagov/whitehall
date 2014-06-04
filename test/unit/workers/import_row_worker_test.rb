require 'test_helper'

class ImportRowWorkerTest < ActiveSupport::TestCase
  include CsvSampleHelpers

  setup do
    create(:importer, name: "Automatic Data Importer")
  end

  test "assigns documents directly to the first group in a draft document collection" do
    perform_import_cleanup do
      collection = create(:draft_document_collection)
      csv_data = publication_csv_sample(document_collection_1: collection.slug)
      import = create(:import, csv_data: csv_data, data_type: "publication")
      worker = ImportRowWorker.new(import.id, import.rows.first, 1)
      worker.run

      assert_equal [], import.import_errors
      assert publication = Publication.first
      assert_equal [collection], publication.document_collections
    end
  end

  test "can import both a normal attachment and an HTML attachment on a publication" do
    perform_import_cleanup do
      stub_request(:get, "http://example.com/attachment.txt").to_return(status: 200, body: "Some text", headers: {})

      csv_data = publication_csv_sample(attachment_1_url: "http://example.com/attachment.txt",
                                        attachment_1_title: 'File title',
                                        html_title: 'HTML title',
                                        html_body: 'body')

      import = create(:import, csv_data: csv_data, data_type: "publication")
      worker = ImportRowWorker.new(import.id, import.rows.first, 1)
      worker.run

      assert_equal [], import.import_errors
      assert publication = Publication.first
      assert_equal 2, publication.attachments.size

      html_attachment = publication.attachments.last
      assert_equal 'HTML title', html_attachment.title
      assert_equal 'body', html_attachment.body

      file_attachment = publication.attachments.first
      assert_equal 'File title', file_attachment.title
    end
  end

  test "creates a new draft of a published document collection before assigning a document to it" do
    perform_import_cleanup do
      collection = create(:published_document_collection)
      csv_data = publication_csv_sample(document_collection_1: collection.slug)
      import = create(:import, csv_data: csv_data, data_type: "publication")
      worker = ImportRowWorker.new(import.id, import.rows.first, 1)
      worker.run

      collection.reload

      assert_equal [], import.import_errors
      assert_equal 2, collection.document.editions.count
      assert_equal "published", collection.state
      assert_equal "draft", collection.document.latest_edition.state
      draft_collection = collection.document.latest_edition
      assert_equal Publication.first.document_collections, [draft_collection]
    end
  end

  test "logs an error if a document collection referenced by an imported document does not exist" do
    perform_import_cleanup do
      csv_data = publication_csv_sample(document_collection_1: "non-existent-collection")
      import = create(:import, csv_data: csv_data, data_type: "publication")
      worker = ImportRowWorker.new(import.id, import.rows.first, 1)
      worker.run

      refute_equal [], import.import_errors
      assert_equal 0, Publication.count
    end
  end

  def perform_import_cleanup(&_block)
    Import.use_separate_connection
    yield
  ensure
    Import.destroy_all
  end

end
