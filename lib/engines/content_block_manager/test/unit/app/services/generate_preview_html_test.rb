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
    "<body class=\"govuk-body\"><p>test</p><span class=\"content-embed content-embed__content_block_email_address\" data-content-block=\"\" data-document-type=\"content_block_email_address\" data-content-id=\"#{preview_content_id}\">example@example.com</span></body>"
  end
  let(:block_render) do
    "<span class=\"content-embed content-embed__content_block_email_address\" data-content-block=\"\" data-document-type=\"content_block_email_address\" data-content-id=\"#{preview_content_id}\">new@new.com</span>"
  end
  let(:block_render_with_style) do
    "<span class=\"content-embed content-embed__content_block_email_address\" data-content-block=\"\" data-document-type=\"content_block_email_address\" data-content-id=\"#{preview_content_id}\" style=\"background-color: yellow;\">new@new.com</span>"
  end
  let(:expected_html) do
    "<body class=\"govuk-body draft\"><p>test</p>#{block_render_with_style}</body>"
  end
  let(:error_html) do
    "<html><body class=\" draft\"><p>Preview not found</p></body></html>"
  end
  let(:document) do
    build(:content_block_document, :email_address, content_id: preview_content_id)
  end
  let(:block_to_preview) do
    build(:content_block_edition, :email_address, document:, details: { "email_address" => "new@new.com" }, id: 1)
  end

  it "returns the preview html" do
    Net::HTTP.expects(:get).with(URI(Plek.website_root + host_base_path)).returns(fake_frontend_response)

    expected_content = Nokogiri::HTML.parse(expected_html).to_s

    actual_content = ContentBlockManager::GeneratePreviewHtml.new(
      content_id: host_content_id,
      content_block_edition: block_to_preview,
      base_path: host_base_path,
    ).call

    assert_equal expected_content, actual_content
  end

  it "shows an error template when the request to the frontend throws an error" do
    exception = StandardError.new("Something went wrong")
    Net::HTTP.expects(:get).with(URI(Plek.website_root + host_base_path)).raises(exception)

    expected_content = Nokogiri::HTML.parse(error_html).to_s

    actual_content = ContentBlockManager::GeneratePreviewHtml.new(
      content_id: host_content_id,
      content_block_edition: block_to_preview,
      base_path: host_base_path,
    ).call

    assert_equal expected_content, actual_content
  end

  it "updates any link paths" do
    fake_frontend_response = "
        <a href='/foo'>Internal link</a>
        <a href='https://example.com'>External link</a>
        <a href='//example.com'>Protocol relative link</a>
      "
    Net::HTTP.expects(:get).with(URI(Plek.website_root + host_base_path)).returns(fake_frontend_response)

    actual_content = ContentBlockManager::GeneratePreviewHtml.new(
      content_id: host_content_id,
      content_block_edition: block_to_preview,
      base_path: host_base_path,
    ).call

    url = host_content_preview_content_block_manager_content_block_edition_path(id: block_to_preview.id, host_content_id:)

    expected_content = Nokogiri::HTML.parse("
        <html>
          <body class=' draft'>
            <a href='#{url}?base_path=/foo' target='_parent'>Internal link</a>
            <a href='https://example.com'>External link</a>
            <a href='//example.com'>Protocol relative link</a>
          </body>
        </html>
      ").to_s

    assert_equal_ignoring_whitespace actual_content.to_s, expected_content
  end
end
