require "test_helper"
require "rake"
class ExportPublicationDataTest < ActiveSupport::TestCase
  CSV_PATH = Rails.root.join("publictions_export.csv")

  teardown do
    File.delete(CSV_PATH) if File.exist?(CSV_PATH)
    Rake::Task["publications:export_for_document_collection"].reenable
  end

  test "export_for_document_collection writes publications to a CSV file" do
    publication = create(:publication, title: "Test Publication", summary: "This is a test publication.")
    Rake.application.invoke_task "publications:export_for_document_collection"

    assert File.exist?(CSV_PATH), "CSV file should be created"
    csv = CSV.read(CSV_PATH, headers: true)
    assert_equal 1, csv.size
    assert_equal publication.title, csv[0]['title']
    assert_equal publication.summary, csv[0]['summary']
  end
end
