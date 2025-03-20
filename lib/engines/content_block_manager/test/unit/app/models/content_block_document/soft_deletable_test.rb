require "test_helper"

class ContentBlockManager::ContentBlock::Document::SoftDeletableTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let(:document) { create(:content_block_document, :email_address) }

  describe "#soft_delete" do
    it "sets the deleted_at column" do
      Timecop.freeze do
        document.soft_delete

        document.reload

        assert_equal document.deleted_at, Time.zone.now
      end
    end
  end

  describe "#soft_deleted?" do
    it "returns true when a record has been soft deleted" do
      document.soft_delete

      assert document.soft_deleted?
    end

    it "returns false when a record has not been soft deleted" do
      assert_not document.soft_deleted?
    end
  end

  it "ensures soft-deleted records do not appear in the default scope" do
    document.soft_delete

    assert_equal [], ContentBlockManager::ContentBlock::Document.all

    assert_raises ActiveRecord::RecordNotFound do
      ContentBlockManager::ContentBlock::Document.find(document.id)
    end
  end
end
