require "test_helper"
require "rake"

class ExportPublicationDataTest < ActiveSupport::TestCase
  CSV_PATH = Rails.root.join("publications_export.csv")

  teardown do
    File.delete(CSV_PATH) if File.exist?(CSV_PATH)
    Rake::Task["publications:export_for_document_collection"].reenable
  end

  test "export_for_document_collection handles no publications" do
    Rake.application.invoke_task "publications:export_for_document_collection"

    assert File.exist?(CSV_PATH), "CSV file should be created"
    csv = CSV.read(CSV_PATH, headers: true)
    assert_equal 0, csv.size, "CSV should be empty when no publications exist"
  end

  test "export_for_document_collection writes publications to a CSV file" do
    publication = create(:published_publication, :with_file_attachment)

    Rake.application.invoke_task "publications:export_for_document_collection[#{publication.organisations.first.slug}]"

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

  test "export_for_document_collection handles multiple publications" do
    organisation = create(:organisation)
    create(:published_publication, :with_file_attachment, organisations: [organisation])
    create(:published_publication, :with_file_attachment, organisations: [organisation])

    Rake.application.invoke_task "publications:export_for_document_collection[#{organisation.slug}]"

    csv = CSV.read(CSV_PATH, headers: true)
    assert_equal 2, csv.size
  end

  test "export_for_document_collection only supports pdf attachments" do
    publication = create(:published_publication, :with_html_attachment)

    Rake.application.invoke_task "publications:export_for_document_collection[#{publication.organisations.first.slug}]"

    csv = CSV.read(CSV_PATH, headers: true)
    assert_equal 1, csv.size
    assert_empty csv[0]['attachment_title']
    assert_empty csv[0]['attachment_filename']
    assert_empty csv[0]['attachment_url']
    assert_empty csv[0]['attachment_created_at']
    assert_empty csv[0]['attachment_updated_at']
  end

  test "export_for_document_collection gets the first pdf attachment" do
    publication = create(:published_publication, :with_html_attachment)
    additional_attachment = create(:file_attachment, attachable: publication)

    Rake.application.invoke_task "publications:export_for_document_collection[#{publication.organisations.first.slug}]"

    csv = CSV.read(CSV_PATH, headers: true)
    assert_equal 1, csv.size
    assert_equal additional_attachment.title, csv[0]['attachment_title']
    assert_equal additional_attachment.filename, csv[0]['attachment_filename']
    assert_equal additional_attachment.url, csv[0]['attachment_url']
  end

  test "export_for_document_collection gets the first pdf attachment if there are multiple" do
    publication = create(:published_publication, :with_html_attachment)
    additional_attachment1 = create(:file_attachment, attachable: publication)
    create(:file_attachment, attachable: publication)

    Rake.application.invoke_task "publications:export_for_document_collection[#{publication.organisations.first.slug}]"

    csv = CSV.read(CSV_PATH, headers: true)
    assert_equal 1, csv.size
    assert_equal additional_attachment1.title, csv[0]['attachment_title']
    assert_equal additional_attachment1.filename, csv[0]['attachment_filename']
    assert_equal additional_attachment1.url, csv[0]['attachment_url']
  end

  test "export_for_document_collection only exports published publications" do
    organisation = create(:organisation)
    published_publication = create(:published_publication, organisations: [organisation])
    create(:draft_publication, organisations: [organisation])

    Rake.application.invoke_task "publications:export_for_document_collection[#{organisation.slug}]"

    csv = CSV.read(CSV_PATH, headers: true)
    assert_equal 1, csv.size
    assert_equal published_publication.title, csv[0]['title']
  end

  test "export_for_document_collection filters by organisation" do
    organisation = create(:organisation)
    publication1 = create(:published_publication, :with_file_attachment, organisations: [organisation])
    publication2 = create(:published_publication, :with_file_attachment)

    Rake.application.invoke_task "publications:export_for_document_collection[#{organisation.slug}]"

    csv = CSV.read(CSV_PATH, headers: true)
    assert_equal 1, csv.size
    assert_equal publication1.title, csv[0]['title']
    refute_includes csv.map { |row| row['title'] }, publication2.title
  end

end
