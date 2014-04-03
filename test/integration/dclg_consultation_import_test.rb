require "test_helper"

class DclgConsultationImportTest < ActiveSupport::TestCase
  test "imports CSV in DCLG format into database" do
    creator = create(:user, name: "Automatic Data Importer")
    organisation = create(:organisation_with_alternative_format_contact_email, name: "department-for-communities-and-local-government")
    policy = create(:policy, title: "supporting-fire-and-rescue-authorities-to-reduce-the-number-and-impact-of-fires")
    stub_request(:get, "http://www.communities.gov.uk/documents/fire/pdf/2205794.pdf").to_return(body: "attachment-content")

    stub_request(:get, "http://www.example.com/documents/response/first-responder.pdf").to_return(body: "response-content")

    filename = Rails.root.join("test/fixtures/dclg_consultation_import_test.csv")
    file = stub("uploaded file", read: File.read(filename), original_filename: filename)
    import = Import.create_from_file(creator, file, "consultation", organisation.id)
    assert import.valid?, import.errors.full_messages.join(", ")

    import.perform

    assert_equal [], import.import_errors

    consultation = Consultation.first
    refute_nil consultation

    assert_equal creator, consultation.creator
    assert_equal [organisation], consultation.organisations
    assert_equal [policy], consultation.related_policies

    assert_equal 1, consultation.attachments.size
    attachment = consultation.attachments.first
    VirusScanHelpers.simulate_virus_scan(attachment.attachment_data.file)
    assert_equal "9781409836148", attachment.isbn
    assert_equal "attachment-content", File.read(attachment.file.path)

    assert outcome = consultation.outcome

    assert_equal 1, outcome.attachments.size
    attachment = outcome.attachments.first
    assert_equal "9780201101799", attachment.isbn
    VirusScanHelpers.simulate_virus_scan(attachment.attachment_data.file)
    assert_equal "response-content", File.read(attachment.file.path)
  end
end
