require "test_helper"

class ContentBlockManager::GetPreviewContentTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let(:described_class) { ContentBlockManager::GetPreviewContent }
  let(:host_content_id) { "64570503-7a7f-4fca-80c1-e6dce7278419" }
  let(:host_title) { "Test" }
  let(:host_base_path) { "/test" }
  let(:uri_mock) { mock }
  let(:fake_frontend_response) do
    "<!DOCTYPE html><body><p>test</p></body>"
  end

  describe "#preview_content" do
    setup do
      stub_publishing_api_has_item(content_id: host_content_id, title: host_title, base_path: host_base_path)
    end

    it "returns the title and raw frontend HTML for a document" do
      Net::HTTP.expects(:get).with(URI(Plek.website_root + host_base_path)).returns(fake_frontend_response)
      Nokogiri::HTML.expects(:parse).with(fake_frontend_response).returns(fake_frontend_response)

      expected_content = {
        title: host_title,
        html: fake_frontend_response,
      }

      assert_equal expected_content, ContentBlockManager::GetPreviewContent.new(content_id: host_content_id).preview_content
    end
  end
end
