require "test_helper"
require "rake"
class ExportPublicationDataTest < ActiveSupport::TestCase
  CSV_PATH = Rails.root.join("publications_export.csv")

  teardown do
    File.delete(CSV_PATH) if File.exist?(CSV_PATH)
    Rake::Task["publications:export_for_document_collection"].reenable
  end

  test "export_for_document_collection writes publications to a CSV file" do
    Rake.application.invoke_task "publications:export_for_document_collection"

    assert File.exist?(CSV_PATH), "CSV file should be created"
  end
end
