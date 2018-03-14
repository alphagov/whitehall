require 'test_helper'

class AssetManagerAttachmentDraftStatusUpdateWorkerTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let(:worker) { AssetManagerAttachmentDraftStatusUpdateWorker.new }
  let(:attachment_data) { attachment.attachment_data }

  context 'when attachment is not a PDF' do
    let(:sample_rtf) { File.open(fixture_path.join('sample.rtf')) }
    let(:attachment) { FactoryBot.create(:file_attachment, file: sample_rtf) }
    let(:draft) { true }

    before do
      AttachmentData.stubs(:find_by).with(id: attachment.id).returns(attachment_data)
      attachment_data.stubs(:draft?).returns(draft)
    end

    it 'marks corresponding asset as draft' do
      AssetManagerUpdateAssetWorker.expects(:perform_async)
        .with(attachment.file.asset_manager_path, draft: true)

      worker.perform(attachment_data.id)
    end
  end

  context 'when attachment cannot be found' do
    it 'does not mark anything as draft' do
      AssetManagerUpdateAssetWorker.expects(:perform_async).never

      worker.perform('no-such-id')
    end
  end

  context 'when attachment is a PDF' do
    let(:simple_pdf) { File.open(fixture_path.join('simple.pdf')) }
    let(:attachment) { FactoryBot.create(:file_attachment, file: simple_pdf) }
    let(:draft) { true }

    before do
      AttachmentData.stubs(:find_by).with(id: attachment.id).returns(attachment_data)
      attachment_data.stubs(:draft?).returns(draft)
    end

    it 'marks asset for attachment & its thumbnail as draft' do
      AssetManagerUpdateAssetWorker.expects(:perform_async)
        .with(attachment.file.asset_manager_path, draft: true)
      AssetManagerUpdateAssetWorker.expects(:perform_async)
        .with(attachment.file.thumbnail.asset_manager_path, draft: true)

      worker.perform(attachment_data.id)
    end

    context 'and attachment should not be draft' do
      let(:draft) { false }

      it 'marks corresponding assets as not draft' do
        AssetManagerUpdateAssetWorker.expects(:perform_async)
          .with(attachment.file.asset_manager_path, draft: false)
        AssetManagerUpdateAssetWorker.expects(:perform_async)
          .with(attachment.file.thumbnail.asset_manager_path, draft: false)

        worker.perform(attachment_data.id)
      end
    end
  end
end
