require 'test_helper'

module ServiceListeners
  class AttachmentDraftStatusUpdaterTest < ActiveSupport::TestCase
    extend Minitest::Spec::DSL

    let(:updater) { AttachmentDraftStatusUpdater.new(attachment_data) }
    let(:attachment_data) { attachment.attachment_data }
    let(:worker) { mock('asset-manager-attachment-draft-status-update-worker') }

    setup do
      AssetManagerAttachmentDraftStatusUpdateWorker.stubs(:new).returns(worker)
    end

    context 'when the attachment has associated attachment data' do
      let(:sample_rtf) { File.open(fixture_path.join('sample.rtf')) }
      let(:attachment) { FactoryBot.create(:file_attachment, file: sample_rtf) }

      it 'call the worker' do
        worker.expects(:perform).with(attachment_data.id)

        updater.update!
      end
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
