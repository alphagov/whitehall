require "test_helper"

class AssetManager::AttachmentUpdaterTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let(:subject) { AssetManager::AttachmentUpdater }
  let(:file) { File.open(fixture_path.join("sample.rtf")) }
  let(:attachment) { FactoryBot.create(:file_attachment, file: file) }
  let(:attachment_data) { attachment.attachment_data }

  it "groups updates together" do
    AssetManager::AssetUpdater.expects(:call).once

    subject.call(attachment_data, redirect_url: true, draft_status: true)
  end
end
