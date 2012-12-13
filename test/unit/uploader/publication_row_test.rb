# encoding: UTF-8

require File.expand_path("../../../fast_test_helper", __FILE__)
require 'whitehall/uploader/publication_row'
require 'test_helper'

class Whitehall::Uploader::PublicationRowTest < ActiveSupport::TestCase
  setup do
    @attachment_cache = stub('attachment cache')
    @default_organisation = stub('Organisation')
  end

  def new_publication_row(csv_data, logger = Logger.new($stdout))
    Whitehall::Uploader::PublicationRow.new(csv_data, 1, @attachment_cache, @default_organisation, logger)
  end

  def basic_headings
    %w{old_url  title summary body  publication_type
      policy_1  policy_2  policy_3  policy_4
      organisation  document_series publication_date
      order_url price ISBN  URN command_paper_number
      country_1 country_2 country_3 country_4}
  end

  test "validates row headings" do
    assert_equal [], Whitehall::Uploader::PublicationRow.heading_validation_errors(basic_headings)
  end

  test "validation reports missing row headings" do
    keys = basic_headings - ['title']
    assert_equal ["missing fields: 'title'"], Whitehall::Uploader::PublicationRow.heading_validation_errors(keys)
  end

  test "validation reports extra row headings" do
    keys = basic_headings + ['extra_stuff']
    assert_equal ["unexpected fields: 'extra_stuff'"], Whitehall::Uploader::PublicationRow.heading_validation_errors(keys)
  end

  test "validation accepts a complete set of attachment headings" do
    keys = basic_headings + %w{attachment_1_url attachment_1_title}
    assert_equal [], Whitehall::Uploader::PublicationRow.heading_validation_errors(keys)
  end

  test "validation complains of missing attachment headings" do
    keys = basic_headings + %w{attachment_1_title}
    assert_equal [
      "missing fields: 'attachment_1_url'",
      ], Whitehall::Uploader::PublicationRow.heading_validation_errors(keys)
  end

  test "takes title from the title column" do
    row = new_publication_row({"title" => "a-title"})
    assert_equal "a-title", row.title
  end

  test "takes summary from the summary column" do
    row = new_publication_row({"summary" => "a-summary"})
    assert_equal "a-summary", row.summary
  end

  test "takes body from the body column" do
    row = new_publication_row({"body" => "Some body goes here"})
    assert_equal "Some body goes here", row.body
  end

  test "takes legacy url from the old_url column" do
    row = new_publication_row({"old_url" => "http://example.com/old-url"})
    assert_equal "http://example.com/old-url", row.legacy_url
  end

  test "finds document series by slug in doc_series column" do
    document_series = create(:document_series)
    row = new_publication_row({"document_series" => document_series.slug})
    assert_equal document_series, row.document_series
  end

  test "finds publication type by slug in the pub type column" do
    row = new_publication_row({"publication_type" => "guidance"})
    assert_equal PublicationType::Guidance, row.publication_type
  end

  test "finds ministers specified by slug in minister 1 and minister 2 columns" do
    minister_1 = create(:person)
    minister_2 = create(:person)
    role_1 = create(:ministerial_role)
    role_2 = create(:ministerial_role)
    create(:role_appointment, role: role_1, person: minister_1)
    create(:role_appointment, role: role_2, person: minister_2)
    row = new_publication_row({ "minister_1" => minister_1.slug,
                                "minister_2" => minister_2.slug,
                                "publication_date" => "16-Nov-2011" })
    assert_equal [role_1, role_2], row.ministerial_roles
  end

  test "finds up to 4 policies specified by slug in columns policy_1, policy_2, policy_3 and policy_4" do
    policy_1 = create(:published_policy, title: "Policy 1")
    policy_2 = create(:published_policy, title: "Policy 2")
    policy_3 = create(:published_policy, title: "Policy 3")
    policy_4 = create(:published_policy, title: "Policy 4")
    row = new_publication_row({ "policy_1" => policy_1.slug,
                                "policy_2" => policy_2.slug,
                                "policy_3" => policy_3.slug,
                                "policy_4" => policy_4.slug })

    assert_equal [policy_1, policy_2, policy_3, policy_4], row.related_policies
  end

  test "finds organisation by name in org column" do
    organisation = create(:organisation)
    row = new_publication_row({"organisation" => organisation.name})
    assert_equal [organisation], row.organisations
  end

  test "generates lead_edition_organisations by asking the edition organisation builder to build a lead with each found organisation" do
    o = stub(:organisation)
    row = new_publication_row({})
    row.stubs(:organisations).returns([o])
    leo = stub(:lead_edition_organisation)
    Whitehall::Uploader::Builders::EditionOrganisationBuilder.stubs(:build_lead).with(o, 1).returns(leo)
    assert_equal [leo], row.lead_edition_organisations
  end

  test "uses the organisation as the alternative format provider" do
    organisation = create(:organisation)
    row = new_publication_row({"organisation" => organisation.name})
    assert_equal organisation, row.alternative_format_provider
  end

  test "finds up to 42 attachments in columns attachment 1 title, attachement 1 url..." do
    @attachment_cache.stubs(:fetch).with("http://example.com/attachment.pdf").returns(File.open(Rails.root.join("test", "fixtures", "two-pages.pdf")))

    row = new_publication_row({
      "attachment_1_title" => "first title",
      "attachment_1_url" => "http://example.com/attachment.pdf" 
    }, Logger.new(StringIO.new))

    attachment = Attachment.new(title: "first title")
    assert_equal [attachment.attributes], row.attachments.collect(&:attributes)
    assert_equal "http://example.com/attachment.pdf", row.attachments.first.attachment_source.url
  end

  test "records the order_url, price, isbn, urn and command_paper_number on the first attachment" do
    @attachment_cache.stubs(:fetch).with("http://example.com/attachment.pdf").returns(File.open(Rails.root.join("test", "fixtures", "two-pages.pdf")))

    row = new_publication_row({
      "attachment_1_title" => "first title",
      "attachment_1_url" => "http://example.com/attachment.pdf",
      "order_url" => "http://example.com/order-it.php",
      "price" => "11.99",
      "isbn" => "1 86192 090 3",
      "urn" => "10/899",
      "command_paper_number" => "Cm 5861"
    }, Logger.new(StringIO.new))

    attachment = Attachment.new(
      title: "first title",
      order_url: "http://example.com/order-it.php",
      price_in_pence: "1199",
      isbn: "1 86192 090 3",
      unique_reference: "10/899",
      command_paper_number: "Cm 5861"
    )
    assert_equal [attachment.attributes], row.attachments.collect(&:attributes)
  end

  test "finds any attachments specified in JSON in the json_attachments column" do
    @attachment_cache.stubs(:fetch).with("http://example.com/attachment.pdf").returns(File.open(Rails.root.join("test", "fixtures", "two-pages.pdf")))

    row = new_publication_row({
      "json_attachments" => ActiveSupport::JSON.encode([{"title" => "first title", "link" => "http://example.com/attachment.pdf"}])
    }, Logger.new(StringIO.new))

    attachment = Attachment.new(title: "first title")
    assert_equal [attachment.attributes], row.attachments.collect(&:attributes)
    assert_equal "http://example.com/attachment.pdf", row.attachments.first.attachment_source.url
  end
end

class Whitehall::Uploader::PublicationRow::AttachmentMetadataBuilderTest < ActiveSupport::TestCase
  def setup
    @attachment = stub_everything('attachment')
  end

  test "does nothing if there are no attachments" do
    Whitehall::Uploader::PublicationRow::AttachmentMetadataBuilder.build(nil, "order-url", "isbn", "urn", "command-paper-number", "")
  end

  test "does nothing if no attributes are set" do
    Whitehall::Uploader::PublicationRow::AttachmentMetadataBuilder.build(@attachment, nil, nil, nil, nil, nil)
  end

  test "sets all attributes if given" do
    @attachment.expects(:order_url=).with("order-url")
    @attachment.expects(:isbn=).with("ISBN")
    @attachment.expects(:unique_reference=).with("unique-reference")
    @attachment.expects(:command_paper_number=).with("command-paper-number")
    @attachment.expects(:price=).with("12.34")
    Whitehall::Uploader::PublicationRow::AttachmentMetadataBuilder.build(@attachment, "order-url", "ISBN", "unique-reference", "command-paper-number", "12.34")
  end

  test "sets any subset of attributes that are given" do
    @attachment.expects(:isbn=).with("ISBN")
    @attachment.expects(:command_paper_number=).with("command-paper-number")
    @attachment.expects(:price=).with("12.34")
    Whitehall::Uploader::PublicationRow::AttachmentMetadataBuilder.build(@attachment, nil, "ISBN", nil, "command-paper-number", "12.34")
  end

  test "finds related world locations using the world location finder" do
    world_locations = 5.times.map { stub('world_location') }
    Whitehall::Uploader::Finders::WorldLocationsFinder.stubs(:find).with("first", "second", "third", "fourth", anything, anything).returns(world_locations)
    row = Whitehall::Uploader::PublicationRow.new({
        "country_1" => "first",
        "country_2" => "second",
        "country_3" => "third",
        "country_4" => "fourth"
      }, 1, stub("cache"), stub("organisation"))
    assert_equal world_locations, row.world_locations
  end
end
