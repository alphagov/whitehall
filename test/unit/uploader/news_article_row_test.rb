require 'test_helper'

module Whitehall::Uploader
  class NewsArticleRowTest < ActiveSupport::TestCase
    setup do
      @attachment_cache = stub('attachment cache')
      @default_organisation = stub("organisation", url: "url")
      @line_number = 1
    end

    def news_article_row(data)
      NewsArticleRow.new(data, @line_number, @attachment_cache, @default_organisation)
    end

    def basic_headings
      %w{old_url news_article_type title summary body first_published policy_1 policy_2 policy_3 policy_4 minister_1 minister_2 organisation country_1 country_2 country_3 country_4}
    end

    test "validates row headings" do
      assert_equal [], NewsArticleRow.heading_validation_errors(basic_headings)
    end

    test "accepts attachment rows" do
      assert_equal [], NewsArticleRow.heading_validation_errors(basic_headings + %w(attachment_1_title attachment_1_url))
      assert_equal [], NewsArticleRow.heading_validation_errors(basic_headings + %w(attachment_1_title attachment_1_url attachment_2_title attachment_2_url))
      assert_equal [], NewsArticleRow.heading_validation_errors(basic_headings + %w(json_attachments))
    end

    test "finds news article type by slug in the news_article_type column" do
      row = news_article_row("news_article_type" => "government-responses")
      assert_equal ::NewsArticleType::GovernmentResponse, row.news_article_type
    end

    test "takes first_published_at from the 'first_published' column" do
      Parsers::DateParser.stubs(:parse).with("first-published-date", anything, anything).returns("date-object")
      row = news_article_row("first_published" => "first-published-date")
      assert_equal "date-object", row.first_published_at
    end

    test "leaves the first_published_at blank if the 'first_published' column is blank" do
      row = news_article_row("first_published" => '')
      assert_nil row.first_published_at
    end

    test "finds related policies using the policy finder" do
      policies = 5.times.map { stub('policy') }
      Finders::PoliciesFinder.stubs(:find).with("first", "second", "third", "fourth", anything, anything).returns(policies)
      row = news_article_row("policy_1" => "first", "policy_2" => "second", "policy_3" => "third", "policy_4" => "fourth")
      assert_equal policies, row.related_editions
    end

    test "finds the roles ministers in minister_1 and minister_2 columns held on the publication date" do
      appointments = 2.times.map { stub('appointment') }
      first_published_at = stub('first-published-at')
      Finders::RoleAppointmentsFinder.stubs(:find).with(first_published_at, "minister-1", "minister-2", anything, anything).returns(appointments)
      row = news_article_row("minister_1" => "minister-1", "minister_2" => "minister-2")
      row.stubs(:first_published_at).returns(first_published_at)
      assert_equal appointments, row.role_appointments
    end

    test "supplies an attribute list for the new news article record" do
      row = news_article_row({})
      attribute_keys = [:title, :summary, :body, :news_article_type, :lead_organisations, :first_published_at, :related_editions, :role_appointments, :world_locations, :attachments]
      attribute_keys.each do |key|
        row.stubs(key).returns(key.to_s)
      end
      expected_attributes = attribute_keys.each.with_object({}) {|key, hash| hash[key] = key.to_s }
      assert_equal expected_attributes, row.attributes
    end

    test "finds related world locations using the world location finder" do
      world_locations = 5.times.map { stub('world_location') }
      Finders::WorldLocationsFinder.stubs(:find).with("first", "second", "third", "fourth", anything, anything).returns(world_locations)
      row = news_article_row("country_1" => "first", "country_2" => "second", "country_3" => "third", "country_4" => "fourth")
      assert_equal world_locations, row.world_locations
    end

    test "finds attachments from the attachment columns" do
      @attachment_cache.stubs(:fetch).with('http://example.com/attachment.pdf', @line_number).returns(File.open(Rails.root.join('test', 'fixtures', 'two-pages.pdf')))
      @attachment_cache.stubs(:fetch).with('http://example.com/second_attachment.pdf', @line_number).returns(File.open(Rails.root.join('test', 'fixtures', 'two-pages.pdf')))

      row = news_article_row({
        'attachment_1_title' => 'first title', 'attachment_1_url' => 'http://example.com/attachment.pdf',
        'attachment_2_title' => 'second title', 'attachment_2_url' => 'http://example.com/second_attachment.pdf'
      })

      assert_equal 2, row.attachments.size
      assert_equal 'first title', row.attachments.first.title
      assert_equal 'http://example.com/attachment.pdf', row.attachments.first.attachment_source.url
      assert_equal 'second title', row.attachments.second.title
      assert_equal 'http://example.com/second_attachment.pdf', row.attachments.second.attachment_source.url
    end

    test "finds attachments from JSON column" do
      @attachment_cache.stubs(:fetch).with("http://example.com/another_attachment.pdf", @line_number).returns(File.open(Rails.root.join("test", "fixtures", "two-pages.pdf")))

      row = news_article_row({
        'json_attachments' => ActiveSupport::JSON.encode([{"title" => "attachment title", "link" => "http://example.com/another_attachment.pdf"}])
      })

      assert_equal 1, row.attachments.size
      assert_equal 'attachment title', row.attachments.first.title
      assert_equal 'http://example.com/another_attachment.pdf', row.attachments.first.attachment_source.url
    end

    test "returns translation attributes" do
      row = news_article_row({
        'title_translation' => 'translated title',
        'body_translation' => 'translated body',
        'summary_translation' => 'translated summary'
      })
      expected_attributes = { title: 'translated title', summary: 'translated summary', body: 'translated body'}

      assert_equal expected_attributes, row.translation_attributes
    end
  end
end
