require 'test_helper'

module ServiceListeners
  class AttachmentDraftStatusUpdaterTest < ActiveSupport::TestCase
    extend Minitest::Spec::DSL

    let(:updater) { AttachmentDraftStatusUpdater.new(attachment_data) }
    let(:attachment_data) { attachment.attachment_data }

    context 'when attachment has no associated attachment data' do
      let(:attachment) { FactoryBot.create(:html_attachment) }

      it 'does not update draft status of any assets' do
        AssetManagerUpdateAssetWorker.expects(:perform_async).never

        updater.update!
      end
    end

    context 'when attachment is not a PDF' do
      let(:sample_rtf) { File.open(fixture_path.join('sample.rtf')) }
      let(:attachment) { FactoryBot.create(:file_attachment, file: sample_rtf) }
      let(:draft) { true }

      before do
        attachment_data.stubs(:draft?).returns(draft)
      end

      it 'marks corresponding asset as draft' do
        AssetManagerUpdateAssetWorker.expects(:perform_async)
          .with(attachment.file.asset_manager_path, draft: true)

        updater.update!
      end
    end

    context 'when attachment is a PDF' do
      let(:simple_pdf) { File.open(fixture_path.join('simple.pdf')) }
      let(:attachment) { FactoryBot.create(:file_attachment, file: simple_pdf) }
      let(:draft) { true }

      before do
        attachment_data.stubs(:draft?).returns(draft)
      end

      it 'marks asset for attachment & its thumbnail as draft' do
        AssetManagerUpdateAssetWorker.expects(:perform_async)
          .with(attachment.file.asset_manager_path, draft: true)
        AssetManagerUpdateAssetWorker.expects(:perform_async)
          .with(attachment.file.thumbnail.asset_manager_path, draft: true)

        updater.update!
      end

      context 'and attachment should not be draft' do
        let(:draft) { false }

        it 'marks corresponding assets as not draft' do
          AssetManagerUpdateAssetWorker.expects(:perform_async)
            .with(attachment.file.asset_manager_path, draft: false)
          AssetManagerUpdateAssetWorker.expects(:perform_async)
            .with(attachment.file.thumbnail.asset_manager_path, draft: false)

          updater.update!
        end
      end
    end
  end
end
