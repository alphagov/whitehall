require "test_helper"

class StatisticalDataSetImportTest < ActiveSupport::TestCase
  def setup
    Import.use_separate_connection
  end

  def teardown
    Import.destroy_all
    ImportError.destroy_all
    ImportLog.destroy_all
  end

  test "imports CSV into database" do
    creator = create(:user, name: "Automatic Data Importer")
    organisation = create(:organisation_with_alternative_format_contact_email, name: "department-for-transport")
    statistical_data_collection = create(:document_collection, title: "Statistical Series 1", lead_organisations: [organisation])
    stub_request(:get, "http://www.example.com/documents/fire/pdf/2205794.pdf").to_return(body: "attachment-content")

    filename = Rails.root.join("test/fixtures/dft_statistical_data_set_sample.csv")
    file = stub("uploaded file", read: File.read(filename), original_filename: filename)
    import = Import.create_from_file(creator, file, "statistical_data_set", organisation.id)
    assert import.valid?, import.errors.full_messages.join(", ")

    import.perform

    assert_equal [], import.import_errors

    statistical_data_set = StatisticalDataSet.first
    refute_nil statistical_data_set

    assert_equal creator, statistical_data_set.creator
    assert_equal [organisation], statistical_data_set.organisations
    assert_equal [statistical_data_collection], statistical_data_set.document_collections
    assert_equal "http://example.com/legacy-url", statistical_data_set.document.document_sources.first.url

    assert_equal "!@1 !@2", statistical_data_set.body

    assert_equal 1, statistical_data_set.attachments.size
    attachment = statistical_data_set.attachments.first
    assert_equal "Attachment title", attachment.title
    assert_equal "attachment-1-urn", attachment.unique_reference
    assert_equal Time.zone.parse("2011-05-23"), attachment.created_at

    VirusScanHelpers.simulate_virus_scan(attachment.attachment_data.file)
    assert_equal "attachment-content", File.read(attachment.file.path)
  end
end
