require "test_helper"

class OfficialDocsImportTest < ActiveSupport::TestCase
  test "importer recognises attachments with hoc/command numbers and parliamentary sessions" do
    creator = User.create!(name: "Automatic Data Importer")
    od_document_collection = create(:document_collection, title: "official-documents")
    hoc_document_collection = create(:document_collection, title: "house-of-commons-papers")
    organisation = create(:organisation_with_alternative_format_contact_email, name: "the-national-archives")

    stub_request(:get, "http://www.official-documents.gov.uk/document/hc0708/hc10/1043/1043.pdf").to_return(body: "attachment-1-content")

    filename = Rails.root.join("test/fixtures/official_docs_import_sample.csv")
    file = stub("uploaded file", read: File.read(filename), original_filename: filename)
    import = Import.create_from_file(creator, file, "publication", organisation.id)
    assert import.valid?, import.errors.full_messages.join(", ")

    without_delay! do
      import.perform
    end

    assert_equal [], import.import_errors

    assert publication = import.editions.first
    assert_equal creator, publication.creator
    assert_equal [organisation], publication.organisations
    assert_equal [od_document_collection, hoc_document_collection], publication.document_collections

    assert_equal 1, publication.attachments.size
    attachment = publication.attachments.first
    VirusScanHelpers.simulate_virus_scan(attachment.attachment_data.file)
    assert_equal "attachment-1-content", File.read(attachment.file.path)
    assert_equal "1043 2007-08", attachment.hoc_paper_number
    assert_equal "2007-08", attachment.parliamentary_session
    refute attachment.unnumbered_command_paper?
    refute attachment.unnumbered_hoc_paper?
  end
end
