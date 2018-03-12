require 'test_helper'

module ServiceListeners
  class AttachmentReplacementIdUpdaterTest < ActiveSupport::TestCase
    extend Minitest::Spec::DSL

    let(:updater) { AttachmentReplacementIdUpdater.new(attachment_data) }

    context 'when attachment data is not nil' do
      let(:attachment_data) { mock('attachment_data', id: 'attachment-data-id') }

      it 'updates replacement ID of any assets' do
        AssetManagerAttachmentReplacementIdUpdateWorker.expects(:perform_async).with('attachment-data-id', nil)

        updater.update!
      end
    end

    context 'when attachment data is nil' do
      let(:attachment_data) { nil }

      it 'does not update replacement ID of any assets' do
        AssetManagerAttachmentReplacementIdUpdateWorker.expects(:perform_async).never

        updater.update!
      end
    end
  end
end
