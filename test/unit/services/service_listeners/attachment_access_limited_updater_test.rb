require 'test_helper'

module ServiceListeners
  class AttachmentAccessLimitedUpdaterTest < ActiveSupport::TestCase
    extend Minitest::Spec::DSL

    let(:updater) { AttachmentAccessLimitedUpdater.new(attachment_data) }
    let(:attachment_data) { attachment.attachment_data }
    let(:worker) { mock('asset-manager-attachment-access-limited-worker') }

    setup do
      AssetManagerAttachmentAccessLimitedWorker.stubs(:new).returns(worker)
    end

    context 'when attachment has no associated attachment data' do
      let(:attachment) { FactoryBot.create(:html_attachment) }

      it 'does not call the worker' do
        worker.expects(:perform).never

        updater.update!
      end
    end
  end
end
