require "test_helper"

class DclgConsultationImportTest < ActiveSupport::TestCase
  test "imports CSV in DCLG format into database" do
    creator = User.create!(name: "Automatic Data Importer")
    organisation = create(:organisation_with_alternative_format_contact_email, name: "department-for-communities-and-local-government")
    policy = create(:policy, title: "supporting-fire-and-rescue-authorities-to-reduce-the-number-and-impact-of-fires")
    stub_request(:get, "http://www.communities.gov.uk/documents/fire/pdf/2205794.pdf").to_return(body: "attachment-content")

    stub_request(:get, "http://www.example.com/documents/response/first-responder.pdf").to_return(body: "response-content")

    data = File.read("test/fixtures/dclg_consultation_import_test.csv")
    ConsultationUploader.new(csv_data: data).upload

    consultation = Consultation.first
    refute_nil consultation

    assert_equal creator, consultation.creator
    assert_equal [organisation], consultation.organisations
    assert_equal [policy], consultation.related_policies

    assert_equal 1, consultation.attachments.size
    attachment = consultation.attachments.first
    assert_equal "9781409836148", attachment.isbn
    assert_equal "attachment-content", File.read(attachment.file.path)

    refute_nil consultation.response
    response = consultation.response

    assert_equal 1, response.attachments.size
    attachment = response.attachments.first
    assert_equal "9780201101799", attachment.isbn
    assert_equal "response-content", File.read(attachment.file.path)
  end
end
