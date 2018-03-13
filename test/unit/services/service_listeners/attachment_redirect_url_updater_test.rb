require 'test_helper'

module ServiceListeners
  class AttachmentRedirectUrlUpdaterTest < ActiveSupport::TestCase
    extend Minitest::Spec::DSL

    let(:updater) { AttachmentRedirectUrlUpdater.new(attachment_data) }
    let(:attachment_data) { attachment.attachment_data }

    context 'when attachment has no associated attachment data' do
      let(:attachment) { FactoryBot.create(:html_attachment) }

      it 'does not update redirect URL of any assets' do
        AssetManagerUpdateAssetWorker.expects(:perform_async).never

        updater.update!
      end
    end
  end
end
