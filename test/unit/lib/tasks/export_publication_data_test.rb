require "test_helper"
require "rake"
class ExportPublicationDataTest < ActiveSupport::TestCase
  CSV_PATH = Rails.root.join("publications_export.csv")

  teardown do
    File.delete(CSV_PATH) if File.exist?(CSV_PATH)
    Rake::Task["publications:export_for_document_collection"].reenable
  end

  test "export_for_document_collection writes publications to a CSV file" do
    publication = create(:publication, :with_file_attachment)

    Rake.application.invoke_task "publications:export_for_document_collection"

    assert File.exist?(CSV_PATH), "CSV file should be created"
    csv = CSV.read(CSV_PATH, headers: true)
    assert_equal 1, csv.size
    assert_equal publication.title, csv[0]['title']
    assert_equal publication.summary, csv[0]['summary']
    assert_equal publication.body, csv[0]['body']
    assert_equal publication.attachments[0].title, csv[0]['attachment_title']
    assert_equal publication.attachments[0].filename, csv[0]['attachment_filename']
    assert_equal publication.attachments[0].url, csv[0]['attachment_url']
    assert_equal publication.attachments[0].created_at, csv[0]['attachment_created_at']
    assert_equal publication.attachments[0].updated_at, csv[0]['attachment_updated_at']
  end
end
