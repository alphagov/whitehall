require "test_helper"

class ContentBlockManager::PreviewContentTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let(:title) { "Ministry of Example" }
  let(:html) { "<p>Ministry of Example</p>" }
  let(:instances_count) { "2" }
  let(:preview_content) { build(:preview_content, title:, instances_count:, html:) }

  it "returns title, html and instances count" do
    assert_equal preview_content.title, title
    assert_equal preview_content.html, html
    assert_equal preview_content.instances_count, instances_count
  end

  describe ".for_content_id" do
    let(:host_content_id) { SecureRandom.uuid }
    let(:preview_content_id) { SecureRandom.uuid }
    let(:host_title) { "Test" }
    let(:host_base_path) { "/test" }
    let(:document) do
      build(:content_block_document, :email_address, content_id: preview_content_id)
    end
    let(:block_to_preview) do
      build(:content_block_edition, :email_address, document:, details: { "email_address" => "new@new.com" }, id: 1)
    end
    let(:metadata_response) do
      stub(:response, parsed_content: { "instances" => 2 })
    end
    let(:preview_response) { stub(:preview_response, call: html) }
    let(:html) { "SOME_HTML" }

    setup do
      stub_publishing_api_has_item(content_id: host_content_id, title: host_title, base_path: host_base_path)
      Services.publishing_api.expects(:get_host_content_item_for_content_id)
              .with(block_to_preview.document.content_id, host_content_id)
              .returns(metadata_response)
    end

    it "returns the title of host document" do
      ContentBlockManager::GeneratePreviewHtml.expects(:new)
                                              .with(content_id: host_content_id,
                                                    content_block_edition: block_to_preview,
                                                    base_path: host_base_path)
                                              .returns(preview_response)

      preview_content = ContentBlockManager::PreviewContent.for_content_id(
        content_id: host_content_id,
        content_block_edition: block_to_preview,
      )

      assert_equal host_title, preview_content.title
      assert_equal 2, preview_content.instances_count
      assert_equal html, preview_content.html
    end

    it "allows a base_path to be provided" do
      base_path = "/something/different"

      ContentBlockManager::GeneratePreviewHtml.expects(:new)
                                              .with(content_id: host_content_id,
                                                    content_block_edition: block_to_preview,
                                                    base_path:)
                                              .returns(preview_response)

      ContentBlockManager::PreviewContent.for_content_id(
        content_id: host_content_id,
        content_block_edition: block_to_preview,
        base_path:,
      )
    end
  end
end
