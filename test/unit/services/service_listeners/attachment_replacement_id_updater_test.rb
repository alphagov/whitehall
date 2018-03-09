require 'test_helper'

module ServiceListeners
  class AttachmentReplacementIdUpdaterTest < ActiveSupport::TestCase
    extend Minitest::Spec::DSL

    let(:updater) { AttachmentReplacementIdUpdater.new(attachment_data) }

    context 'when attachment data is nil' do
      let(:attachment_data) { nil }

      it 'does not update replacement ID of any assets' do
        AssetManagerUpdateAssetWorker.expects(:perform_async).never

        updater.update!
      end
    end
  end
end
