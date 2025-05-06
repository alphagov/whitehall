require "test_helper"

class ContentBlockManager::GeneratePreviewHtmlTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL
  include ContentBlockManager::Engine.routes.url_helpers
  include TextAssertions

  let(:host_content_id) { SecureRandom.uuid }
  let(:preview_content_id) { SecureRandom.uuid }
  let(:host_title) { "Test" }
  let(:host_base_path) { "/test" }
  let(:uri_mock) { mock }

  let(:fake_frontend_response) do
    "<body class=\"govuk-body\"><p>test</p><span class=\"content-embed content-embed__content_block_email_address\" data-content-block=\"\" data-document-type=\"content_block_email_address\" data-embed-code=\"embed-code\" data-content-id=\"#{preview_content_id}\">example@example.com</span></body>"
  end
  let(:block_render) do
    "<span class=\"content-embed content-embed__content_block_email_address\" data-content-block=\"\" data-document-type=\"content_block_email_address\" data-embed-code=\"embed-code\" data-content-id=\"#{preview_content_id}\"><a class=\"govuk-link\" href=\"mailto:new@new.com\">new@new.com</a></span>"
  end

  let(:document) do
    build(:content_block_document, :email_address, content_id: preview_content_id)
  end

  let(:block_to_preview) do
    build(:content_block_edition, :email_address, document:, details: { "email_address" => "new@new.com" }, id: 1)
  end

  before do
    Net::HTTP.stubs(:get).with(URI("#{Plek.website_root}#{host_base_path}")).returns(fake_frontend_response)
    block_to_preview.stubs(:render).returns(block_render)
  end

  it "returns the preview html" do
    actual_content = ContentBlockManager::GeneratePreviewHtml.new(
      content_id: host_content_id,
      content_block_edition: block_to_preview,
      base_path: host_base_path,
      locale: "en",
    ).call

    parsed_content = Nokogiri::HTML.parse(actual_content)

    assert_dom parsed_content, "body.draft"
    assert_dom parsed_content, 'span.content-embed__content_block_email_address[style="background-color: yellow;"]'
  end

  describe "when the frontend throws an error" do
    before do
      exception = StandardError.new("Something went wrong")
      Net::HTTP.expects(:get).with(URI("#{Plek.website_root}#{host_base_path}")).raises(exception)
    end

    it "shows an error template" do
      expected_content = Nokogiri::HTML.parse("<html><body class=\" draft\"><p>Preview not found</p></body></html>").to_s

      actual_content = ContentBlockManager::GeneratePreviewHtml.new(
        content_id: host_content_id,
        content_block_edition: block_to_preview,
        base_path: host_base_path,
        locale: "en",
      ).call

      assert_equal expected_content, actual_content
    end
  end

  describe "when the frontend response contains links" do
    let(:fake_frontend_response) do
      "
        <a href='/foo'>Internal link</a>
        <a href='https://example.com'>External link</a>
        <a href='//example.com'>Protocol relative link</a>
      "
    end

    it "updates any link paths" do
      actual_content = ContentBlockManager::GeneratePreviewHtml.new(
        content_id: host_content_id,
        content_block_edition: block_to_preview,
        base_path: host_base_path,
        locale: "en",
      ).call

      url = host_content_preview_content_block_manager_content_block_edition_path(id: block_to_preview.id, host_content_id:)

      parsed_content = Nokogiri::HTML.parse(actual_content)

      internal_link = parsed_content.xpath("//a")[0]
      external_link = parsed_content.xpath("//a")[1]
      protocol_relative_link = parsed_content.xpath("//a")[2]

      assert_equal internal_link.attribute("href").to_s, "#{url}?locale=en&base_path=/foo"
      assert_equal internal_link.attribute("target").to_s, "_parent"

      assert_equal external_link.attribute("href").to_s, "https://example.com"

      assert_equal protocol_relative_link.attribute("href").to_s, "//example.com"
    end
  end

  describe "when the wrapper is a div" do
    let(:fake_frontend_response) do
      "<body class=\"govuk-body\"><p>test</p><div class=\"content-embed content-embed__content_block_email_address\" data-content-block=\"\" data-document-type=\"content_block_email_address\" data-embed-code=\"embed-code\" data-content-id=\"#{preview_content_id}\">example@example.com</div></body>"
    end
    let(:block_render) do
      "<div class=\"content-embed content-embed__content_block_email_address\" data-content-block=\"\" data-document-type=\"content_block_email_address\" data-embed-code=\"embed-code\" data-content-id=\"#{preview_content_id}\"><a class=\"govuk-link\" href=\"mailto:new@new.com\">new@new.com</a></div>"
    end

    it "returns the preview html" do
      actual_content = ContentBlockManager::GeneratePreviewHtml.new(
        content_id: host_content_id,
        content_block_edition: block_to_preview,
        base_path: host_base_path,
        locale: "en",
      ).call

      parsed_content = Nokogiri::HTML.parse(actual_content)

      assert_dom parsed_content, "body.draft"
      assert_dom parsed_content, 'div.content-embed__content_block_email_address[style="background-color: yellow;"]'
    end
  end
end
