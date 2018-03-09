require 'test_helper'

module ServiceListeners
  class AttachmentReplacementIdUpdaterTest < ActiveSupport::TestCase
    extend Minitest::Spec::DSL

    let(:updater) { AttachmentReplacementIdUpdater.new(attachment_data) }

    context 'when attachment data has a replacement' do
      let(:attachment_data) { mock('attachment_data', id: 'attachment-data-id', replaced_by: mock('replacement')) }

      it 'updates replacement ID of any assets' do
        AssetManagerAttachmentReplacementIdUpdateWorker.expects(:perform_async).with('attachment-data-id', nil)

        updater.update!
      end
    end

    context 'when a queue is specified' do
      let(:updater) { AttachmentReplacementIdUpdater.new(attachment_data, queue: 'a-queue') }
      let(:attachment_data) { mock('attachment_data', id: 'attachment-data-id', replaced_by: mock('replacement')) }

      it 'sets the queue on the worker' do
        worker = mock('worker', perform_async: nil)
        AssetManagerAttachmentReplacementIdUpdateWorker.expects(:set).with(queue: 'a-queue').returns(worker)

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

    context 'when attachment data has not been replaced' do
      let(:attachment_data) { mock('attachment_data', replaced_by: nil) }

      it 'does not update replacement ID of any assets' do
        AssetManagerAttachmentReplacementIdUpdateWorker.expects(:perform_async).never

        updater.update!
      end
    end
  end
end
