require 'test_helper'

class ConsultationUploaderTest < ActiveSupport::TestCase
  setup do
    @logger = stub_everything("Logger")
    @example_organisation = create(:organisation,
      name: "Example organisation",
      alternative_format_contact_email: "alternative@example.com")
  end

  test "a basic edition gets created with the title, summary and body and the source url is recorded" do
    uploader = ConsultationUploader.new(
      import_as: create(:user),
      csv_data: csv_sample(
        "old_url" => "http://example.com",
        "title" => "title",
        "summary" => "summary",
        "body" => "body",
        "opening_date" => "9/25/2009",
        "closing_date" => "12/24/2009",
      ),
      logger: @logger
    )
    uploader.upload
    assert consultation = Consultation.first
    assert_equal "title", consultation.title
    assert_equal "summary", consultation.summary
    assert_equal "body", consultation.body
    assert_equal Date.parse("2009-09-25"), consultation.opening_on
    assert_equal Date.parse("2009-12-24"), consultation.closing_on
    assert_equal "http://example.com", consultation.document.document_source.url
  end

  test "policies specified by slug are associated with the edition" do
    example_policy = create(:published_policy, title: "Example policy")
    uploader = ConsultationUploader.new(
      import_as: create(:user),
      csv_data: csv_sample("policy 1" => "example-policy"),
      logger: @logger
    )
    uploader.upload
    assert consultation = Consultation.first
    assert_equal [example_policy], consultation.related_policies
  end

  test "organisation specified by name is associated with the edition" do
    uploader = ConsultationUploader.new(
      import_as: create(:user),
      csv_data: csv_sample("organisation" => "Example organisation"),
      logger: @logger
    )
    uploader.upload
    assert consultation = Consultation.first
    assert_equal [@example_organisation], consultation.organisations
  end

  test "alternative format provider is set from organisation" do
    uploader = ConsultationUploader.new(
      import_as: create(:user),
      csv_data: csv_sample("organisation" => "Example organisation"),
      logger: @logger
    )
    uploader.upload
    assert consultation = Consultation.first
    assert_equal "alternative@example.com", consultation.alternative_format_contact_email
  end

  test "raises if ministerial roles in csv" do
    uploader = ConsultationUploader.new(
      import_as: create(:user),
      csv_data: csv_sample("minister 1" => "some-ministerial-role"),
      logger: @logger
    )
    assert_raises RuntimeError do
      uploader.upload
    end
  end

  test "a response is added if a reponse date is specified in the csv" do
    uploader = ConsultationUploader.new(
      import_as: create(:user),
      csv_data: csv_sample("response date" => "1/25/2012"),
      logger: @logger
    )
    uploader.upload
    assert consultation = Consultation.first
    assert consultation.response.present?
    assert_equal Date.parse("2012-01-25"), consultation.response.published_on
  end

  test "if an edition with the same source url already exists, the row is ignored and a warning is issued" do
    @logger.expects :warn
    create(:document_source, url: "http://example.com")
    uploader = ConsultationUploader.new(
      import_as: create(:user),
      csv_data: csv_sample("old_url" => "http://example.com"),
      logger: @logger
    )
    uploader.upload
    assert_equal 0, Consultation.count
  end

  test "attachments listed in the attachment columns in the CSV get downloaded and associated with the created edition" do
    stub_request(:get, "http://example.com/beard_length_consultation.pdf").to_return(body: "some-data".force_encoding("ASCII-8BIT"), status: 200)

    uploader = ConsultationUploader.new(
      import_as: create(:user),
      csv_data: csv_sample(
        "attachment_1" => "http://example.com/beard_length_consultation.pdf",
        "attachment_1_title" => "Beard length consultation"
      ),
      logger: @logger
    )
    uploader.upload
    assert consultation = Consultation.first
    assert attachment = consultation.attachments.first
    assert_equal "beard_length_consultation.pdf", attachment.filename
    assert attachment.file.present?
    assert_equal "some-data", File.read(attachment.file.path)
    assert_equal "Beard length consultation", attachment.title
  end

  test "attachment missing a title is still uploaded with warning" do
    stub_request(:get, "http://example.com/beard_length_consultation.pdf").to_return(body: "some-data".force_encoding("ASCII-8BIT"), status: 200)

    uploader = ConsultationUploader.new(
      import_as: create(:user),
      csv_data: csv_sample(
        "attachment_1" => "http://example.com/beard_length_consultation.pdf",
        "attachment_1_title" => ""
      ),
      logger: @logger
    )
    @logger.expects(:warn)
    uploader.upload
    assert attachment = Consultation.first.attachments.first
    assert_equal "Unknown", attachment.title
  end

  test "source url is recorded for attachments" do
    stub_request(:get, "http://example.com/beard_length_consultation.pdf").to_return(body: "some-data".force_encoding("ASCII-8BIT"), status: 200)

    uploader = ConsultationUploader.new(
      import_as: create(:user),
      csv_data: csv_sample(
        "attachment_1" => "http://example.com/beard_length_consultation.pdf",
        "attachment_1_title" => "Beard length consultation"
      ),
      logger: @logger
    )
    uploader.upload
    assert_equal "http://example.com/beard_length_consultation.pdf", Consultation.first.attachments.first.attachment_source.url
  end

  test "attachments listed in the response attachment columns get downloaded and associated with the response" do
    stub_request(:get, "http://example.com/beard_length_consultation_response.pdf").to_return(body: "some-response-data".force_encoding("ASCII-8BIT"), status: 200)

    uploader = ConsultationUploader.new(
      import_as: create(:user),
      csv_data: csv_sample(
        "response date" => "01/19/2010",
        "response_1" => "http://example.com/beard_length_consultation_response.pdf",
        "response_1_title" => "Beard length consultation response"
      ),
      logger: @logger
    )
    uploader.upload
    assert consultation = Consultation.first
    assert attachment = consultation.response.attachments.first
    assert_equal "beard_length_consultation_response.pdf", attachment.filename
    assert attachment.file.present?
    assert_equal "some-response-data", File.read(attachment.file.path)
    assert_equal "Beard length consultation response", attachment.title
  end

  test "source url is recorded for response attachments" do
    stub_request(:get, "http://example.com/beard_length_consultation_response.pdf").to_return(body: "some-data".force_encoding("ASCII-8BIT"), status: 200)

    uploader = ConsultationUploader.new(
      import_as: create(:user),
      csv_data: csv_sample(
        "response_1" => "http://example.com/beard_length_consultation_response.pdf",
        "response_1_title" => "Beard length consultation response"
      ),
      logger: @logger
    )
    uploader.upload
    assert_equal "http://example.com/beard_length_consultation_response.pdf", Consultation.first.response.attachments.first.attachment_source.url
  end

  test "response attachments added even if no response date" do
    stub_request(:get, "http://example.com/beard_length_consultation_response.pdf").to_return(body: "some-response-data".force_encoding("ASCII-8BIT"), status: 200)

    uploader = ConsultationUploader.new(
      import_as: create(:user),
      csv_data: csv_sample(
        "response date" => "",
        "response_1" => "http://example.com/beard_length_consultation_response.pdf",
        "response_1_title" => "Beard length consultation response"
      ),
      logger: @logger
    )
    uploader.upload
    assert consultation = Consultation.first
    assert attachment = consultation.response.attachments.first
    assert_equal "beard_length_consultation_response.pdf", attachment.filename
    assert attachment.file.present?
  end

  test "a validation error when saving a consultation prevents only that consultation from being created" do
    data = csv_sample({"title" => ""}, [{"title" => "title2"}])

    uploader = ConsultationUploader.new(
      import_as: create(:user),
      csv_data: data,
      logger: @logger
    )
    uploader.upload
    assert_equal 1, Consultation.count
    assert consultation = Consultation.first
    assert_equal "title2", consultation.title
  end

  test "timeout when fetching an attachment logs an error and skips the attachment" do
    stub_request(:get, "http://example.com/beard_length_consultation.pdf").to_timeout
    data = csv_sample(
      {
        "title" => "title",
        "attachment_1" => "http://example.com/beard_length_consultation.pdf",
        "attachment_1_title" => "Beard length consultation"
      },
      [{"old_url" => "http://example.com/2", "title" => "title2"}])

    uploader = ConsultationUploader.new(
      import_as: create(:user),
      csv_data: data,
      logger: @logger
    )
    @logger.expects(:error)
    uploader.upload
    assert_equal 2, Consultation.count
    c1, c2 = Consultation.all
    assert_equal "title", c1.title
    assert_equal 0, c1.attachments.count
    assert_equal "title2", c2.title
  end

  test "connection refused when fetching an attachment logs an error and skips the attachment" do
    url = "http://example.com/beard_length_consultation.pdf"
    stub_request(:get, url).to_raise(Errno::ECONNREFUSED)
    data = csv_sample("attachment_1" => url, "attachment_1_title" => "blc")
    uploader = ConsultationUploader.new(
      import_as: create(:user),
      csv_data: data,
      logger: @logger
    )
    @logger.expects(:error)
    uploader.upload
    assert_equal 1, Consultation.count
    assert_equal 0, Consultation.first.attachments.size
  end

  test "connection reset when fetching an attachment logs an error and skips the attachment" do
    url = "http://example.com/beard_length_consultation.pdf"
    stub_request(:get, url).to_raise(Errno::ECONNRESET)
    data = csv_sample("attachment_1" => url, "attachment_1_title" => "blc")
    uploader = ConsultationUploader.new(
      import_as: create(:user),
      csv_data: data,
      logger: @logger
    )
    @logger.expects(:error)
    uploader.upload
    assert_equal 1, Consultation.count
    assert_equal 0, Consultation.first.attachments.size
  end

  test "404 when fetching an attachment logs an error and skips the attachment" do
    url = "http://example.com/beard_length_consultation.pdf"
    stub_request(:get, url).to_return(body: "not-found".force_encoding("ASCII-8BIT"), status: 404)
    data = csv_sample("attachment_1" => url, "attachment_1_title" => "blc")
    uploader = ConsultationUploader.new(
      import_as: create(:user),
      csv_data: data,
      logger: @logger
    )
    @logger.expects(:error).with(regexp_matches(/404/))
    uploader.upload
    assert_equal 1, Consultation.count
    assert_equal 0, Consultation.first.attachments.size
  end

  test "site-relative urls in the summary or body get prefixed with the original domain" do
    @example_organisation.url = "http://example.com"
    @example_organisation.save!
    uploader = ConsultationUploader.new(
      import_as: create(:user),
      csv_data: csv_sample(
        "summary" => "[Summary link](/summary/) [Absolute link](http://other.com/)",
        "body" => "[Body link](/body/)"
      ),
      logger: @logger
    )
    uploader.upload
    assert consultation = Consultation.first
    assert_equal "[Summary link](http://example.com/summary/) [Absolute link](http://other.com/)", consultation.summary
    assert_equal "[Body link](http://example.com/body/)", consultation.body
  end

private
  def csv_sample(additional_fields = {}, extra_rows = [])
    data = default_row.merge(additional_fields)
    lines = []
    lines << CSV.generate_line(data.keys, encoding: "UTF-8")
    lines << CSV.generate_line(data.values, encoding: "UTF-8")
    extra_rows.each do |row|
      lines << CSV.generate_line(default_row.merge(row).values, encoding: "UTF-8")
    end
    lines.join
  end

  def default_row
    {
      "old_url" => "http://example.com",
      "title" => "title",
      "summary" => "summary",
      "body" => "body",
      "opening_date" => "9/25/2009",
      "closing_date" => "12/24/2009",
      "organisation" => "Example organisation"
    }
  end
end