require "test_helper"

class AssetManager::AttachmentDeleterTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe AssetManager::AttachmentDeleter do
    let(:worker) { AssetManager::AttachmentDeleter }
    let(:delete_worker) { mock("delete-worker") }
    let(:attachment_data) { build(:attachment_data) }

    around do |test|
      AssetManager.stub_const(:AssetDeleter, delete_worker) do
        test.call
      end
    end

    before do
      attachment_data.stubs(:deleted?).returns(deleted)
    end

    context "attachment data is not deleted" do
      let(:deleted) { false }

      it "does not delete any assets from Asset Manager" do
        delete_worker.expects(:call).never

        worker.call(attachment_data)

        assert AssetManagerDeleteAssetWorker.jobs.empty?
      end
    end

    context "attachment data is deleted" do
      let(:deleted) { true }

      it "deletes attachment asset in Asset Manager" do
        delete_worker.expects(:call).with("asset_manager_id_original")

        worker.call(attachment_data)
      end
    end
  end
end
