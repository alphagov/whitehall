require "test_helper"
require "rake"

class DeleteContentBlockTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  teardown do
    Rake::Task["content_block_manager:delete_content_block"].reenable
  end

  describe "when a content block exists" do
    let!(:content_block_document) { create(:content_block_document, :pension) }
    let!(:content_block_editions) { create_list(:content_block_edition, 5, document: content_block_document) }

    let(:content_id) { content_block_document.content_id }

    it "returns an error if the document has host content" do
      stub_response = stub("ContentBlockManager::HostContentItem::Items", items: stub(count: 2))
      ContentBlockManager::HostContentItem.stubs(:for_document).with(content_block_document).returns(stub_response)

      assert_raises RuntimeError, "Content block `#{content_id}` cannot be deleted because it has host content. Try removing the dependencies and trying again" do
        Rake::Task["content_block_manager:delete_content_block[#{content_id}]"].execute
      end

      content_block_document.reload

      assert_not content_block_document.soft_deleted?
    end

    describe "when the document does not have host content" do
      before do
        stub_response = stub("ContentBlockManager::HostContentItem::Items", items: stub(count: 0))
        ContentBlockManager::HostContentItem.stubs(:for_document).with(content_block_document).returns(stub_response)
      end

      it "destroys the content block" do
        Services.publishing_api.expects(:unpublish).with(
          content_id,
          type: "vanish",
          locale: "en",
          discard_drafts: true,
        )

        Rake.application.invoke_task("content_block_manager:delete_content_block[#{content_id}]")

        content_block_document.reload

        assert content_block_document.soft_deleted?
      end
    end
  end

  it "returns an error if the content block cannot be found" do
    content_id = SecureRandom.uuid

    assert_raises RuntimeError, "A content block with the content ID `#{content_id}` cannot be found" do
      Rake::Task["content_block_manager:delete_content_block[#{content_id}]"].execute
    end
  end
end
