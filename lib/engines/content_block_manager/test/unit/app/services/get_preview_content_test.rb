require "test_helper"

class ContentBlockManager::GetPreviewContentTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let(:described_class) { ContentBlockManager::GetPreviewContent }
  let(:host_content_id) { SecureRandom.uuid }
  let(:preview_content_id) { SecureRandom.uuid }
  let(:host_title) { "Test" }
  let(:host_base_path) { "/test" }
  let(:uri_mock) { mock }
  let(:fake_frontend_response) do
    "<body><p>test</p><span class=\"content-embed content-embed__content_block_email_address\" data-content-block=\"\" data-document-type=\"content_block_email_address\" data-content-id=\"#{preview_content_id}\">example@example.com</span></body>"
  end
  let(:block_render) do
    "<span class=\"content-embed content-embed__content_block_email_address\" data-content-block=\"\" data-document-type=\"content_block_email_address\" data-content-id=\"#{preview_content_id}\">new@new.com</span>"
  end
  let(:block_render_with_style) do
    "<span class=\"content-embed content-embed__content_block_email_address\" data-content-block=\"\" data-document-type=\"content_block_email_address\" data-content-id=\"#{preview_content_id}\" style=\"background-color: yellow;\">new@new.com</span>"
  end
  let(:expected_html) do
    "<body><p>test</p>#{block_render_with_style}</body>"
  end
  let(:document) do
    build(:content_block_document, :email_address, content_id: preview_content_id)
  end
  let(:block_to_preview) do
    build(:content_block_edition, :email_address, document:, details: { "email_address" => "new@new.com" })
  end

  describe "#preview_content" do
    setup do
      stub_publishing_api_has_item(content_id: host_content_id, title: host_title, base_path: host_base_path)
    end

    it "returns the title and preview HTML for a document" do
      Net::HTTP.expects(:get).with(URI(Plek.website_root + host_base_path)).returns(fake_frontend_response)
      block_to_preview.expects(:render).returns(block_render)

      expected_content = {
        title: host_title,
        html: Nokogiri::HTML.parse(expected_html),
      }

      actual_content = ContentBlockManager::GetPreviewContent.for_content_id(
        content_id: host_content_id,
        content_block_edition: block_to_preview,
      )

      assert_equal expected_content[:title], actual_content.title
      assert_equal expected_content[:html].to_s, actual_content.html.to_s
    end
  end
end
