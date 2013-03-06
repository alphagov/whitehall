# encoding: UTF-8
require 'test_helper'

module Whitehall::Uploader
  class DetailedGuideRowTest < ActiveSupport::TestCase
    setup do
      @attachment_cache = stub('attachment cache')
      @default_organisation = stub('Organisation')
    end

    def new_detailed_guide_row(csv_data, logger = Logger.new($stdout))
      Whitehall::Uploader::DetailedGuideRow.new(csv_data, 1, @attachment_cache, @default_organisation, logger)
    end

    def basic_headings
      %w{
        old_url
        title summary body
        organisation
        topic_1 topic_2
        detailed_guidance_category_1 detailed_guidance_category_2
        document_series_1 document_series_2
        related_detailed_guide_1 related_detailed_guide_2
        related_mainstream_content_url_1 related_mainstream_content_title_1
        related_mainstream_content_url_2 related_mainstream_content_title_2
        first_published
      }
    end

    test "validates row headings" do
      assert_equal [], Whitehall::Uploader::DetailedGuideRow.heading_validation_errors(basic_headings)
    end

    test "validation reports missing row headings" do
      keys = basic_headings - ['title']
      assert_equal ["missing fields: 'title'"], Whitehall::Uploader::DetailedGuideRow.heading_validation_errors(keys)
    end

    test "validation reports extra row headings" do
      keys = basic_headings + ['extra_stuff']
      assert_equal ["unexpected fields: 'extra_stuff'"], Whitehall::Uploader::DetailedGuideRow.heading_validation_errors(keys)
    end

    test "validation accepts a complete set of attachment headings" do
      keys = basic_headings + %w{attachment_1_url attachment_1_title}
      assert_equal [], Whitehall::Uploader::DetailedGuideRow.heading_validation_errors(keys)
    end

    test "validation complains of missing attachment headings" do
      keys = basic_headings + %w{attachment_1_title}
      assert_equal [
        "missing fields: 'attachment_1_url'",
        ], Whitehall::Uploader::DetailedGuideRow.heading_validation_errors(keys)
    end

    test "takes title from the title column" do
      row = new_detailed_guide_row({"title" => "a-title"})
      assert_equal "a-title", row.attributes[:title]
    end

    test "takes summary from the summary column" do
      row = new_detailed_guide_row({"summary" => "a-summary"})
      assert_equal "a-summary", row.attributes[:summary]
    end

    test 'if summary column is blank, generates summary from body' do
      row = new_detailed_guide_row("summary" => '', "body" => 'woo')
      Parsers::SummariseBody.stubs(:parse).with('woo').returns('w')
      assert_equal 'w', row.attributes[:summary]
    end

    test "takes body from the body column" do
      row = new_detailed_guide_row({"body" => "Some body goes here"})
      assert_equal "Some body goes here", row.attributes[:body]
    end

    test "takes legacy urls from the old_url column" do
      row = new_detailed_guide_row({"old_url" => "http://example.com/old-url"})
      assert_equal ["http://example.com/old-url"], row.legacy_urls
    end

    test "parses legacy url using OldUrlParser" do
      old_url_json = stub("old url json")
      parsed_old_urls = stub("parsed urls")
      Parsers::OldUrlParser.stubs(:parse).with(old_url_json, anything, anything).returns(parsed_old_urls)
      row = new_detailed_guide_row({"old_url" => old_url_json})
      assert_equal parsed_old_urls, row.legacy_urls
    end

    test "finds document series by slug in document_series_n column" do
      document_series = create(:document_series)
      row = new_detailed_guide_row({"document_series_1" => document_series.slug})
      assert_equal [document_series], row.attributes[:document_series]
    end

    test "finds topics by slug in topic_n column" do
      topic = create(:topic)
      row = new_detailed_guide_row({"topic_1" => topic.slug})
      assert_equal [topic], row.attributes[:topics]
    end

    test "finds primary mainstream category by slug in detailed_guidance_category_1 column" do
      category = create(:mainstream_category, title: "My Detailed Guidance")
      row = new_detailed_guide_row("detailed_guidance_category_1" => category.slug)
      assert_equal category, row.attributes[:primary_mainstream_category]
    end

    test "finds other mainstream categories by slug in detailed_guidance_category_n column" do
      category_1 = create(:mainstream_category, title: "My Detailed Guidance")
      category_2 = create(:mainstream_category, title: "Other Detailed Guidance")
      row = new_detailed_guide_row(
        "detailed_guidance_category_1" => category_1.slug,
        "detailed_guidance_category_2" => category_2.slug
      )
      assert_equal [category_2], row.attributes[:other_mainstream_categories]
    end

    test "finds document series by slug from document_series_n column" do
      series = create(:document_series)
      row = new_detailed_guide_row({"document_series_1" => series.slug})
      assert_equal [series], row.attributes[:document_series]
    end

    test "finds related detailed guide by slug from related_detailed_guide_n column" do
      detailed_guide = create(:published_detailed_guide)
      row = new_detailed_guide_row({"related_detailed_guide_1" => detailed_guide.slug})
      assert_equal [detailed_guide.document], row.attributes[:outbound_related_documents]
    end

    test "related mainstream content url and title set from appropriate fields in CSV input" do
      row = new_detailed_guide_row(
        "related_mainstream_content_url_1" => "http://example.com/1",
        "related_mainstream_content_title_1" => "Example 1",
        "related_mainstream_content_url_2" => "http://example.com/2",
        "related_mainstream_content_title_2" => "Example 2"
        )
      assert_equal "http://example.com/1", row.attributes[:related_mainstream_content_url]
      assert_equal "Example 1", row.attributes[:related_mainstream_content_title]
      assert_equal "http://example.com/2", row.attributes[:additional_related_mainstream_content_url]
      assert_equal "Example 2", row.attributes[:additional_related_mainstream_content_title]
    end

    test "takes lead_organisations from the found organisations" do
      o = stub(:organisation)
      row = new_detailed_guide_row({})
      row.stubs(:organisations).returns([o])
      assert_equal [o], row.attributes[:lead_organisations]
    end

    test "uses the organisation as the alternative format provider" do
      organisation = create(:organisation)
      row = new_detailed_guide_row({"organisation" => organisation.name})
      assert_equal organisation, row.attributes[:alternative_format_provider]
    end

    test "finds up to 42 attachments in columns attachment 1 title, attachement 1 url..." do
      @attachment_cache.stubs(:fetch).with("http://example.com/attachment.pdf").returns(File.open(Rails.root.join("test", "fixtures", "two-pages.pdf")))

      row = new_detailed_guide_row({
        "attachment_1_title" => "first title",
        "attachment_1_url" => "http://example.com/attachment.pdf"
      }, Logger.new(StringIO.new))

      attachment = Attachment.new(title: "first title")
      assert_equal [attachment.attributes], row.attachments.collect(&:attributes)
      assert_equal "http://example.com/attachment.pdf", row.attachments.first.attachment_source.url
    end

    test "finds first published" do
      row = new_detailed_guide_row("first_published" => "11-Jan-2011")
      assert_equal Time.zone.parse("2011-01-11"), row.attributes[:first_published_at]
    end
  end
end