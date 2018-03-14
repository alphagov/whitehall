require 'test_helper'

module ServiceListeners
  class AttachmentAccessLimitedUpdaterTest < ActiveSupport::TestCase
    extend Minitest::Spec::DSL

    let(:updater) { AttachmentAccessLimitedUpdater.new(attachment_data) }
    let(:attachment_data) { attachment.attachment_data }

    context 'when attachment has no associated attachment data' do
      let(:attachment) { FactoryBot.create(:html_attachment) }

      it 'does not update draft status of any assets' do
        AssetManagerUpdateAssetWorker.expects(:perform_async).never

        updater.update!
      end
    end
  end
end
