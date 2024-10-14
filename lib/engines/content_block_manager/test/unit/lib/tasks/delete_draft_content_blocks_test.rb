require "test_helper"
require "rake"

class ContentBlockManager::DeleteDraftContentBlocksTest < ActiveSupport::TestCase
  teardown do
    Rake::Task["content_block_manager:delete_draft_content_blocks"].reenable
  end

  test "deletes draft Content Block Editions" do
    document = create(:content_block_document, :email_address)
    create_list(:content_block_edition, 2, :email_address, document:, state: :published)
    create_list(:content_block_edition, 2, :email_address, document:, state: :draft)
    assert_changes -> { ContentBlockManager::ContentBlock::Edition.count }, from: 4, to: 2 do
      assert_no_changes -> { ContentBlockManager::ContentBlock::Document.count } do
        Rake.application.invoke_task("content_block_manager:delete_draft_content_blocks")
      end
    end
  end

  test "deletes orphaned Content Block Documents" do
    document = create(:content_block_document, :email_address)
    create_list(:content_block_edition, 2, :email_address, document:, state: :draft)
    assert_changes -> { ContentBlockManager::ContentBlock::Edition.count }, from: 2, to: 0 do
      assert_changes -> { ContentBlockManager::ContentBlock::Document.count }, from: 1, to: 0 do
        Rake.application.invoke_task("content_block_manager:delete_draft_content_blocks")
      end
    end
  end
end
