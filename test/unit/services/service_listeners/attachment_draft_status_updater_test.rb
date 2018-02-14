require 'test_helper'

module ServiceListeners
  class AttachmentDraftStatusUpdaterTest < ActiveSupport::TestCase
    extend Minitest::Spec::DSL

    let(:updater) { AttachmentDraftStatusUpdater.new(attachment) }
    let(:visibility) { stub('visibility', visible?: visible) }
    let(:visible) { false }

    before do
      AttachmentVisibility.stubs(:new).returns(visibility)
    end

    context 'when attachment is not a file attachment' do
      let(:attachment) { FactoryBot.create(:html_attachment) }

      it 'does not update draft status of any assets' do
        AssetManagerUpdateAssetWorker.expects(:perform_async).never

        updater.update!
      end
    end

    context 'when attachment is not a PDF' do
      let(:sample_rtf) { File.open(fixture_path.join('sample.rtf')) }
      let(:attachment) { FactoryBot.create(:file_attachment, file: sample_rtf) }

      it 'updates draft status of corresponding asset' do
        AssetManagerUpdateAssetWorker.expects(:perform_async)
          .with(attachment.file.asset_manager_path, draft: true)

        updater.update!
      end
    end

    context 'when attachment is a PDF' do
      let(:simple_pdf) { File.open(fixture_path.join('simple.pdf')) }
      let(:attachment) { FactoryBot.create(:file_attachment, file: simple_pdf) }

      it 'updates draft status of asset for attachment & its thumbnail' do
        AssetManagerUpdateAssetWorker.expects(:perform_async)
          .with(attachment.file.asset_manager_path, draft: true)
        AssetManagerUpdateAssetWorker.expects(:perform_async)
          .with(attachment.file.thumbnail.asset_manager_path, draft: true)

        updater.update!
      end

      context 'and attachment should be visible, i.e. not draft' do
        let(:visible) { true }

        it 'updates draft status of asset for attachment & its thumbnail' do
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
