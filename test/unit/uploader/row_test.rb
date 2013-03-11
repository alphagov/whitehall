require 'fast_test_helper'
require 'whitehall/uploader'

module Whitehall::Uploader
  class RowTest < ActiveSupport::TestCase
    setup do
      @attachment_cache = stub('attachment cache')
      @default_organisation = stub('Organisation')
    end

    test "validates row headings" do
      assert_equal [], Row.heading_validation_errors(basic_headings)
    end

    test "validation reports missing row headings" do
      keys = basic_headings - ['title']
      assert_equal ["missing fields: 'title'"], Row.heading_validation_errors(keys)
    end

    test "validation reports extra row headings" do
      keys = basic_headings + ['extra_stuff']
      assert_equal ["unexpected fields: 'extra_stuff'"], Row.heading_validation_errors(keys)
    end

    test "takes title from the title column" do
      row = build_row("title" => "a-title")
      assert_equal "a-title", row.title
    end

    test "takes summary from the summary column, converting relative links to absolute" do
      Parsers::RelativeToAbsoluteLinks.stubs(:parse).with("relative links", "url").returns("absolute links")
      row = build_row("summary" => "relative links")
      row.stubs(:organisation).returns(stubbed_organisation)
      assert_equal "absolute links", row.summary
    end

    test 'if summary column is blank, generates summary from body' do
      row = build_row("summary" => '', "body" => 'woo')
      row.stubs(:organisation).returns(stubbed_organisation)
      Parsers::SummariseBody.stubs(:parse).with('woo').returns('w')
      assert_equal 'w', row.summary
    end

    test "takes legacys url from the old_url column" do
      row = build_row("old_url" => "http://example.com/old-url")
      assert_equal ["http://example.com/old-url"], row.legacy_urls
    end

    test "takes body from the 'body' column, converting relative links to absolute" do
      Parsers::RelativeToAbsoluteLinks.expects(:parse).with("relative links", "url").returns("absolute links")
      row = build_row("body" => "relative links")
      row.stubs(:organisation).returns(stubbed_organisation)
      assert_equal "absolute links", row.body
    end

    test "constructs a long body from multiple body fields to work around CSV cell size limits" do
      csv_data = {
        "body" => "body0\n",
        "body_1" => "body1\n",
        "body_2" => "body2\n",
        "body_3" => "body3\n",
        "body_4" => "body4\n",
        "body_5" => "body5\n"
      }
      row = build_row(csv_data)
      row.stubs(:organisation).returns(stubbed_organisation)
      assert_equal csv_data.values.join(''), row.body
    end

    test "finds an organisation using the organisation finder" do
      organisation = stubbed_organisation
      Finders::OrganisationFinder.stubs(:find).with("name or slug", anything, anything, @default_organisation).returns([organisation])
      row = build_row("organisation" => "name or slug")
      assert_equal organisation, row.organisation
    end

    test "takes organisations as an array containing the found organisation" do
      row = build_row({})
      row.stubs(:organisation).returns(:organisation)
      assert_equal [:organisation], row.organisations
    end

    test "takes lead_organisations from the found organisations" do
      organisation = stubbed_organisation
      row = build_row({})
      row.stubs(:organisations).returns([organisation])
      assert_equal [organisation], row.lead_organisations
    end

    test "recognises the presence of a translation" do
      refute build_row({}).translation_present?
      assert build_row({'locale' => 'es'}).translation_present?
    end

    test "returns the locale" do
      assert_equal 'es', build_row('locale' => 'es').translation_locale
    end

    test "returns the tranlsation url" do
      assert_equal 'http://web.com/article.es', build_row('translation_url' => 'http://web.com/article.es').translation_url
    end

    test "returns the translated title from the title_translation" do
      row = build_row("title_translation" => "a-title")
      assert_equal "a-title", row.translated_title
    end

    test "returns the translated summary from the summary_translation column, converting relative links to absolute" do
      Parsers::RelativeToAbsoluteLinks.stubs(:parse).with("translated summary with relative links", "url").returns("translated summary with absolute links")
      row = build_row("summary_translation" => "translated summary with relative links")
      row.stubs(:organisation).returns(stubbed_organisation)
      assert_equal "translated summary with absolute links", row.translated_summary
    end

    test 'generates the translated summary from the translated body if the translated summary column is blank' do
      row = build_row("summary_translation" => '', "body_translation" => 'translated body')
      row.stubs(:organisation).returns(stubbed_organisation)
      Parsers::SummariseBody.stubs(:parse).with('translated body').returns('translated summary')
      assert_equal 'translated summary', row.translated_summary
    end

    test "returns the translated body from the 'body_tranlsation' column, converting relative links to absolute" do
      Parsers::RelativeToAbsoluteLinks.expects(:parse).with("translated body with relative links", "url").returns("translated body with absolute links")
      row = build_row("body_translation" => "translated body with relative links")
      row.stubs(:organisation).returns(stubbed_organisation)
      assert_equal "translated body with absolute links", row.translated_body
    end

    private

    def build_row(data)
      Row.new(data, 1, @attachment_cache, @default_organisation)
    end

    def basic_headings
      %w{old_url title summary body organisation}
    end

    def stubbed_organisation
      stub("organisation", url: "url")
    end
  end
end