# encoding: UTF-8
# *NOTE* this file deliberately does not include test_helper
# in order to attempt to speed up the tests

require File.expand_path("../../../fast_test_helper", __FILE__)
require 'whitehall/uploader/statistical_data_set_row'

module Whitehall::Uploader
  class StatisticalDataSetRowTest < ActiveSupport::TestCase
    setup do
      @attachment_cache = stub('attachment cache')
      @default_organisation = stub('Organisation')
    end

    def statistica_data_set_row(data)
      StatisticalDataSetRow.new(data, 1, @attachment_cache, @default_organisation)
    end

    def basic_headings
      %w{old_url title summary body organisation data_series}
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

    test "takes title from the title column" do
      row = statistica_data_set_row("title" => "a-title")
      assert_equal "a-title", row.title
    end

    test "takes summary from the summary column" do
      row = statistica_data_set_row("summary" => "a-summary")
      assert_equal "a-summary", row.summary
    end

    test "takes body from the body column" do
      row = statistica_data_set_row("body" => "Some body goes here")
      assert_equal "Some body goes here", row.body
    end

    test "generates a body linking to all attachments where the body is empty" do
      attachments, attributes = attachments_and_attributes_for(10)

      row = statistica_data_set_row(attributes.merge("body" => " "))
      body_referencing_attachments = (1..10).map { |i| "!@#{i}" }.join("\n\n")
      assert_equal body_referencing_attachments, row.body
    end

    test "should have a legacy url from the old_url column" do
      row = statistica_data_set_row("old_url" => "http://example.com/legacy-url")
      assert_equal "http://example.com/legacy-url", row.legacy_url
    end

    test "finds document series by slug in data_series column" do
      document_series = stub("document series")
      Finders::DocumentSeriesFinder.stubs(:find).with("name or slug", anything, anything).returns([document_series])
      row = statistica_data_set_row("data_series" => "name or slug")
      assert_equal [document_series], row.document_series
    end

    test "finds organisation by slug in org column" do
      organisation = stub("organisation")
      Finders::OrganisationFinder.stubs(:find).with("name or slug", anything, anything, @default_organisation).returns([organisation])
      row = statistica_data_set_row("organisation" => "name or slug")
      assert_equal [organisation], row.organisations
    end

    test "generates lead_edition_organisations by asking the edition organisation builder to build a lead with each found organisation" do
      o = stub(:organisation)
      row = statistica_data_set_row({})
      row.stubs(:organisations).returns([o])
      leo = stub(:lead_edition_organisation)
      Whitehall::Uploader::Builders::EditionOrganisationBuilder.stubs(:build_lead).with(o, 1).returns(leo)
      assert_equal [leo], row.lead_edition_organisations
    end

    test "uses the organisation as the alternative format provider" do
      organisation = stub("organisation")
      Finders::OrganisationFinder.stubs(:find).with("name or slug", anything, anything, @default_organisation).returns([organisation])
      row = statistica_data_set_row("organisation" => "name or slug")
      assert_equal organisation, row.alternative_format_provider
    end

    test "finds up to 100 attachments in columns attachment 1 title, attachement 1 url..." do
      attachments, attributes = attachments_and_attributes_for(100)

      row = statistica_data_set_row(attributes)

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
