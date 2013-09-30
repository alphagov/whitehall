require 'test_helper'

module Whitehall::Uploader
  class PublicationRowTest < ActiveSupport::TestCase
    setup do
      @attachment_cache = stub('attachment cache')
      @default_organisation = stub('Organisation', url: 'url')
      @line_number = 1
    end

    def new_publication_row(csv_data={}, logger = Logger.new($stdout))
      Whitehall::Uploader::PublicationRow.new(csv_data, @line_number, @attachment_cache, @default_organisation, logger)
    end

    def basic_headings
      %w{old_url  title summary body  publication_type
        policy_1  policy_2  policy_3  policy_4
        organisation  document_collection_1 document_collection_2
        document_collection_3 document_collection_4 publication_date
        order_url price ISBN  URN command_paper_number
        country_1 country_2 country_3 country_4}
    end

    test "validates row headings" do
      assert_equal [], Whitehall::Uploader::PublicationRow.heading_validation_errors(basic_headings)
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

    test "validation accepts optional HTML title and body" do
      keys = basic_headings + %w(html_title html_body)
      assert_equal [], Whitehall::Uploader::PublicationRow.heading_validation_errors(keys)
    end

    test "validation accepts HTML body across multiple columns" do
      keys = basic_headings + %w(html_title html_body html_body_1 html_body_2 html_body_3)
      assert_equal [], Whitehall::Uploader::PublicationRow.heading_validation_errors(keys)
    end

    test "finds document collections by slug in document_collection_n column" do
      document_collection = create(:document_collection)
      row = new_publication_row({"document_collection_1" => document_collection.slug})
      assert_equal [document_collection], row.document_collection
    end

    test "finds publication type by slug in the pub type column" do
      row = new_publication_row({"publication_type" => "guidance"})
      assert_equal PublicationType::Guidance, row.attributes[:publication_type]
    end

    test "parses the published date from the publication_date column" do
      row = new_publication_row({"publication_date" => "16-May-12"})
      assert_equal Date.parse("2012-05-16"), row.attributes[:first_published_at]
    end

    test "leaves the published date blank if the publication_date column is blank" do
      row = new_publication_row({"publication_date" => ""})
      assert_nil row.attributes[:first_published_at]
    end

    test "combines HTML body parts if present" do
      assert_nil new_publication_row.html_body

      row = new_publication_row({'html_body' => 'body', 'html_body_1' => ' part 1', 'html_body_2' => ' part 2'})
      assert_equal 'body part 1 part 2', row.attributes[:html_version_attributes][:body]
    end

    test "returns the HTML title if present" do
      assert_nil new_publication_row.html_title

      row = new_publication_row({'html_title' => 'HTML title'})
      assert_equal 'HTML title', row.attributes[:html_version_attributes][:title]
    end

    test "sets nested attributes for an HTML version if present" do
      row_with_html_version = new_publication_row({'html_title' => 'HTML title', 'html_body' => 'HTML body'})
      assert_equal 'HTML title', row_with_html_version.attributes[:html_version_attributes][:title]
      assert_equal 'HTML body', row_with_html_version.attributes[:html_version_attributes][:body]
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
      assert_equal [role_1, role_2], row.attributes[:ministerial_roles]
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

      assert_equal [policy_1, policy_2, policy_3, policy_4], row.attributes[:related_editions]
    end

    test "uses the organisation as the alternative format provider" do
      organisation = create(:organisation)
      row = new_publication_row({"organisation" => organisation.name})
      assert_equal organisation, row.attributes[:alternative_format_provider]
    end

    test "finds up to 42 attachments in columns attachment 1 title, attachement 1 url..." do
      @attachment_cache.stubs(:fetch).with("http://example.com/attachment.pdf", @line_number).returns(File.open(Rails.root.join("test", "fixtures", "two-pages.pdf")))

      row = new_publication_row({
        "attachment_1_title" => "first title",
        "attachment_1_url" => "http://example.com/attachment.pdf"
      }, Logger.new(StringIO.new))

      attachment = Attachment.new(title: "first title")
      assert_equal [attachment.attributes], row.attributes[:attachments].collect(&:attributes)
      assert_equal "http://example.com/attachment.pdf", row.attributes[:attachments].first.attachment_source.url
    end

    test "records any meta data onto the first attachment" do
      @attachment_cache.stubs(:fetch).with("http://example.com/attachment.pdf", @line_number).returns(File.open(Rails.root.join("test", "fixtures", "two-pages.pdf")))

      row = new_publication_row({
        "attachment_1_title" => "first title",
        "attachment_1_url" => "http://example.com/attachment.pdf",
        "order_url" => "http://example.com/order-it.php",
        "price" => "11.99",
        "isbn" => "1 86192 090 3",
        "urn" => "10/899"
      }, Logger.new(StringIO.new))

      attachment = Attachment.new(
        title: "first title",
        order_url: "http://example.com/order-it.php",
        price_in_pence: "1199",
        isbn: "1 86192 090 3",
        unique_reference: "10/899"
      )
      assert_equal [attachment.attributes], row.attributes[:attachments].collect(&:attributes)
    end

    test "records any parlimentary paper information to the first attachment" do
      @attachment_cache.stubs(:fetch).with("http://example.com/attachment.pdf", @line_number).returns(File.open(Rails.root.join("test", "fixtures", "two-pages.pdf")))

      row = new_publication_row({
        'attachment_1_title' =>'title',
        'attachment_1_url' => 'http://example.com/attachment.pdf',
        'command_paper_number' => 'Cm 5861',
        'hoc_paper_number' => '123456',
        'parliamentary_session' => '2010-11',
        'unnumbered_hoc_paper' => 'true',
        'unnumbered_command_paper' => '',
      }, Logger.new(StringIO.new))

      attachment = Attachment.new(
        title: "title",
        command_paper_number: 'Cm 5861',
        hoc_paper_number: '123456',
        parliamentary_session: '2010-11',
        unnumbered_hoc_paper: true,
        unnumbered_command_paper: nil
      )
      assert_equal [attachment.attributes], row.attributes[:attachments].collect(&:attributes)
    end

    test "finds any attachments specified in JSON in the json_attachments column" do
      @attachment_cache.stubs(:fetch).with("http://example.com/attachment.pdf", @line_number).returns(File.open(Rails.root.join("test", "fixtures", "two-pages.pdf")))

      row = new_publication_row({
        "json_attachments" => ActiveSupport::JSON.encode([{"title" => "first title", "link" => "http://example.com/attachment.pdf"}])
      }, Logger.new(StringIO.new))

      attachment = Attachment.new(title: "first title")
      assert_equal [attachment.attributes], row.attributes[:attachments].collect(&:attributes)
      assert_equal "http://example.com/attachment.pdf", row.attributes[:attachments].first.attachment_source.url
    end

    test "finds related world locations using the world location finder" do
      world_locations = 5.times.map { stub('world_location') }
      Whitehall::Uploader::Finders::WorldLocationsFinder.stubs(:find).with("first", "second", "third", "fourth", anything, anything).returns(world_locations)
      row = new_publication_row({
          "country_1" => "first",
          "country_2" => "second",
          "country_3" => "third",
          "country_4" => "fourth"
        })
      assert_equal world_locations, row.attributes[:world_locations]
    end
  end
end
