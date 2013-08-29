require "test_helper"

class DftPublicationWithJsonImportTest < ActiveSupport::TestCase
  test "imports CSV in DFT format (including JSON attachments) into database" do
    creator = User.create!(name: "Automatic Data Importer")
    document_series = create(:document_series, name: "Highways orders inspectors reports and decision letters")
    organisation = create(:organisation_with_alternative_format_contact_email, name: "department-for-transport")
    policy = create(:policy, title: "managing-improving-and-investing-in-the-road-network")
    stub_request(:get, "http://assets.dft.gov.uk/publications/a5m1-dunstable-norther-bypass/inspector-report.pdf").to_return(body: "attachment-content")

    filename = Rails.root.join("test/fixtures/dft_publication_import_with_json_test.csv")
    file = stub("uploaded file", read: File.read(filename), original_filename: filename)
    import = Import.create_from_file(creator, file, "publication", organisation.id)
    assert import.valid?, import.errors.full_messages.join(", ")
    import.perform

    assert_equal [], import.import_errors

    publication = Publication.first
    refute_nil publication

    assert_equal creator, publication.creator
    assert_equal [organisation], publication.organisations
    assert_equal [policy], publication.related_policies
    assert_equal Date.new(2012, 10, 19), publication.first_published_at.to_date

    assert_equal 1, publication.attachments.size
    attachment = publication.attachments.first
    VirusScanHelpers.simulate_virus_scan(attachment.attachment_data.file)
    assert_equal "attachment-content", File.read(attachment.file.path)
  end
end
