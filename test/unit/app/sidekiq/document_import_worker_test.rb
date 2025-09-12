require "test_helper"
require "gds_api/test_helpers/publishing_api"

class DocumentImportWorkerTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::PublishingApi

  setup do
    @path_to_import_file = "test/fixtures/document_importer/example.json"
    @stubbed_data = stub(
      id: 123,
      live_edition: build(
        :standard_edition,
        configurable_document_type: "press_release",
        document: build(:document, slug: "press-release-for-test-purposes"),
      ),
    )
  end

  test "imports a document into Whitehall" do
    PublishingApiDocumentRepublishingWorker.stubs(:new).returns(stub(perform: true))

    Whitehall::DocumentImporter.expects(:import!).with { |data|
      assert_equal "/government/news/press-release-for-test-purposes", data["base_path"]
      assert_equal "Press release for test purposes", data["title"]
      assert_equal "This is a test summary for a test press release.", data["summary"]
      assert_equal "press_release", data["document_type"]
      assert_equal "published", data["state"]
      assert_equal "36d03d5e-eac6-4c18-9d29-f02f6bbf6cc1", data["content_id"]
    }.returns(@stubbed_data)

    DocumentImportWorker.new.perform(@path_to_import_file)
  end

  test "overwrites the existing route in Publishing API" do
    PublishingApiDocumentRepublishingWorker.stubs(:new).returns(stub(perform: true))
    Whitehall::DocumentImporter.stubs(:import!).returns(@stubbed_data)

    Services.publishing_api.expects(:put_path).with(
      "/government/news/press-release-for-test-purposes",
      {
        publishing_app: "whitehall",
        override_existing: true,
      },
    )

    DocumentImportWorker.new.perform(@path_to_import_file)
  end

  test "republishes the document" do
    Whitehall::DocumentImporter.stubs(:import!).returns(@stubbed_data)

    PublishingApiDocumentRepublishingWorker.any_instance.expects(:perform).with(123)

    DocumentImportWorker.new.perform(@path_to_import_file)
  end

  test "raises an error if the JSON is invalid" do
    invalid_path = "test/fixtures/document_importer/bad_example.json"

    assert_raises(RuntimeError, "Failed to parse JSON for #{invalid_path}") do
      DocumentImportWorker.new.perform(invalid_path)
    end
  end
end
