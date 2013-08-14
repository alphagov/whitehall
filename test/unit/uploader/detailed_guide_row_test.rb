# encoding: UTF-8
require 'test_helper'

module Whitehall::Uploader
  class DetailedGuideRowTest < ActiveSupport::TestCase
    setup do
      @attachment_cache = stub('attachment cache')
      @default_organisation = stub('Organisation', url: 'url')
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

    test "finds document series by slug in document_series_n column" do
      document_series = create(:document_series)
      row = new_detailed_guide_row({"document_series_1" => document_series.slug})
      assert_equal [document_series], row.document_series
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

    test "finds related detailed guide by slug from related_detailed_guide_n column" do
      detailed_guide = create(:published_detailed_guide)
      row = new_detailed_guide_row({"related_detailed_guide_1" => detailed_guide.slug})
      assert_equal [detailed_guide.document], row.attributes[:outbound_related_documents]
    end

    test "returns lead_organisations as an attribute" do
      organisation = stub("organisation", url: "url")
      row = new_detailed_guide_row({})
      row.stubs(:organisations).returns([organisation])
      assert_equal [organisation], row.lead_organisations
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