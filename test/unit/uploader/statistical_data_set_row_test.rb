require 'fast_test_helper'
require 'whitehall/uploader'

module Whitehall::Uploader
  class StatisticalDataSetRowTest < ActiveSupport::TestCase
    setup do
      @attachment_cache = stub('attachment cache')
      @default_organisation = stub('Organisation')
    end

    def statistical_data_set_row(data)
      StatisticalDataSetRow.new(data, 1, @attachment_cache, @default_organisation)
    end

    def basic_headings
      %w{old_url title summary body organisation data_collection first_published}
    end

    test "validates row headings" do
      assert_equal [], StatisticalDataSetRow.heading_validation_errors(basic_headings)
    end

    test "validation reports missing row headings" do
      keys = basic_headings - ['title']
      assert_equal ["missing fields: 'title'"], StatisticalDataSetRow.heading_validation_errors(keys)
    end

    test "validation reports extra row headings" do
      keys = basic_headings + ['extra_stuff']
      assert_equal ["unexpected fields: 'extra_stuff'"], StatisticalDataSetRow.heading_validation_errors(keys)
    end

    test "validation accepts a complete set of attachment headings" do
      keys = basic_headings + %w{attachment_1_url attachment_1_title attachment_1_URN attachment_1_published_date}
      assert_equal [], StatisticalDataSetRow.heading_validation_errors(keys)
    end

    test "validation complains of missing attachment headings" do
      keys = basic_headings + %w{attachment_1_title attachment_1_URN attachment_1_published_date}
      assert_equal [
        "missing fields: 'attachment_1_url'",
        ], StatisticalDataSetRow.heading_validation_errors(keys)
    end

    test 'validation accepts a change_note heading' do
      assert_equal [], StatisticalDataSetRow.heading_validation_errors(basic_headings + ['change_note'])
    end

    test "takes title from the title column" do
      row = statistical_data_set_row("title" => "a-title")
      assert_equal "a-title", row.title
    end

    test "takes summary from the summary column" do
      row = statistical_data_set_row("summary" => "a-summary")
      assert_equal "a-summary", row.summary
    end

    test 'if summary column is blank, generates summary from body' do
      row = statistical_data_set_row("summary" => '', "body" => 'woo')
      Parsers::SummariseBody.stubs(:parse).with('woo').returns('w')
      assert_equal 'w', row.summary
    end

    test "takes body from the body column" do
      row = statistical_data_set_row("body" => "Some body goes here")
      assert_equal "Some body goes here", row.body
    end

    test "takes first_published_at from the 'first_published' column" do
      Parsers::DateParser.stubs(:parse).with("first-published-date", anything, anything).returns("date-object")
      row = statistical_data_set_row("first_published" => "first-published-date")
      assert_equal "date-object", row.first_published_at
    end

    test "takes change_note from the change_note column" do
      row = statistical_data_set_row("change_note" => "a-change-note")
      assert_equal "a-change-note", row.change_note
    end

    test 'if change_note column is blank, uses default change_note for imported statistical data sets' do
      row = statistical_data_set_row("change_note" => '')
      Parsers::SummariseBody.stubs(:parse).with('woo').returns('w')
      assert_equal StatisticalDataSetRow::DEFAULT_CHANGE_NOTE, row.change_note
    end

    test "access_limited is always false" do
      row = statistical_data_set_row({})
      row.stubs(:organisations).returns([])
      assert_includes row.attributes.keys, :access_limited
      assert_equal false, row.attributes[:access_limited]
    end

    test "generates a body linking to all attachments where the body is empty" do
      attachments, attributes = attachments_and_attributes_for(10)

      row = statistical_data_set_row(attributes.merge("body" => " "))
      body_referencing_attachments = (1..10).map { |i| "!@#{i}" }.join("\n\n")
      assert_equal body_referencing_attachments, row.body
    end

    test "should have a legacy url from the old_url column" do
      row = statistical_data_set_row("old_url" => "http://example.com/legacy-url")
      assert_equal ["http://example.com/legacy-url"], row.legacy_urls
    end

    test "returns document collection slugs from document_collection_n columns, rejecting blanks" do
      row = statistical_data_set_row(
        "document_collection_1" => "collection-slug",
        "document_collection_2" => ""
      )
      assert_equal ["collection-slug"], row.document_collections
    end

    test "finds organisation by slug in org column" do
      organisation = stub("organisation")
      Finders::OrganisationFinder.stubs(:find).with("name or slug", anything, anything, @default_organisation).returns([organisation])
      row = statistical_data_set_row("organisation" => "name or slug")
      assert_equal [organisation], row.organisations
    end

    test "takes lead_organisations from the found organisations" do
      o = stub(:organisation)
      row = statistical_data_set_row({})
      row.stubs(:organisations).returns([o])
      assert_equal [o], row.lead_organisations
    end

    test "uses the organisation as the alternative format provider" do
      organisation = stub("organisation")
      Finders::OrganisationFinder.stubs(:find).with("name or slug", anything, anything, @default_organisation).returns([organisation])
      row = statistical_data_set_row("organisation" => "name or slug")
      assert_equal organisation, row.alternative_format_provider
    end

    test "finds up to 100 attachments in columns attachment 1 title, attachement 1 url..." do
      attachments, attributes = attachments_and_attributes_for(100)

      row = statistical_data_set_row(attributes)

      assert_equal attachments.first, row.attachments.first
      assert_equal attachments.last, row.attachments.last
    end

    private

    def attachments_and_attributes_for(count)
      attachments = (1..count).map {|i| stub_everything("attachment-#{i}") }

      attributes = (1..count).each.with_object({}) do |i, hash|
        url = "http://example.com/attachment-#{i}.pdf"
        title = "title #{i}"
        unique_reference = "urn-#{i}"
        publication_date = Date.today - i
        hash["attachment_#{i}_title"] = title
        hash["attachment_#{i}_url"] = url
        hash["attachment_#{i}_urn"] = unique_reference
        hash["attachment_#{i}_published_date"] = publication_date
        Builders::AttachmentBuilder.stubs(:build).with({title: title, unique_reference: unique_reference, created_at: publication_date}, url, @attachment_cache, anything, anything).returns(attachments[i - 1])
      end

      [attachments, attributes]
    end
  end
end
