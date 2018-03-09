require 'test_helper'

module ServiceListeners
  class AttachmentReplacementIdUpdaterTest < ActiveSupport::TestCase
    extend Minitest::Spec::DSL

    let(:updater) { AttachmentReplacementIdUpdater.new(attachment_data) }
    let(:worker) { mock('worker') }

    setup do
      AssetManagerAttachmentReplacementIdUpdateWorker.stubs(:new).returns(worker)
    end

    context 'when attachment data has a replacement' do
      let(:attachment_data) { mock('attachment_data', id: 'attachment-data-id', replaced_by: mock('replacement')) }

      it 'updates replacement ID of any assets' do
        worker.expects(:perform).with('attachment-data-id', nil)

        updater.update!
      end
    end

    context 'when attachment data is nil' do
      let(:attachment_data) { nil }

      it 'does not update replacement ID of any assets' do
        worker.expects(:perform).never

        updater.update!
      end
    end

    context 'when attachment data has not been replaced' do
      let(:attachment_data) { mock('attachment_data', replaced_by: nil) }

      it 'does not update replacement ID of any assets' do
        worker.expects(:perform).never

        updater.update!
      end
    end
  end
end
