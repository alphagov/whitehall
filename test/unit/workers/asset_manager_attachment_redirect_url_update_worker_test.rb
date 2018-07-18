require 'test_helper'

class AssetManagerAttachmentRedirectUrlUpdateWorkerTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let(:file) { File.open(fixture_path.join("sample.rtf")) }
  let(:attachment) { FactoryBot.create(:file_attachment, file: file) }
  let(:attachment_data) { attachment.attachment_data }
  let(:worker) { AssetManagerAttachmentRedirectUrlUpdateWorker.new }

  it "calls AssetManager::AttachmentRedirectUrlUpdater" do
    AssetManager::AttachmentRedirectUrlUpdater.expects(:call).with(attachment_data)
    worker.perform(attachment_data.id)
  end
end
