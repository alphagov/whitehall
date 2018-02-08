require 'test_helper'

module ServiceListeners
  class AttachmentDraftStatusUpdaterTest < ActiveSupport::TestCase
    extend Minitest::Spec::DSL

    let(:edition) { create(:news_article) }
    let(:updater) { AttachmentDraftStatusUpdater.new(edition) }
    let(:visibility) { stub('visibility', visible?: visible) }
    let(:visible) { false }

    before do
      AttachmentVisibility.stubs(:new).returns(visibility)
    end

    context 'when edition does not allow attachments' do
      let(:edition) { create(:speech) }

      it 'does not update draft status of any assets' do
        AssetManagerUpdateAssetWorker.expects(:perform_async).never

        updater.update!
      end
    end

    context 'when edition has only non-file attachments' do
      before do
        edition.attachments << FactoryBot.build(:html_attachment)
        edition.attachments << FactoryBot.build(:external_attachment)
      end

      it 'does not update draft status of any assets' do
        AssetManagerUpdateAssetWorker.expects(:perform_async).never

        updater.update!
      end
    end

    context 'when edition has non-pdf attachments' do
      let(:sample_rtf) { File.open(fixture_path.join('sample.rtf')) }
      let(:sample_docx) { File.open(fixture_path.join('sample.docx')) }
      let(:rtf_attachment) { FactoryBot.build(:file_attachment, file: sample_rtf) }
      let(:docx_attachment) { FactoryBot.build(:file_attachment, file: sample_docx) }

      before do
        edition.attachments << rtf_attachment
        edition.attachments << docx_attachment
      end

      it 'updates draft status of asset for each attachment' do
        AssetManagerUpdateAssetWorker.expects(:perform_async)
          .with(rtf_attachment.file.asset_manager_path, draft: true)
        AssetManagerUpdateAssetWorker.expects(:perform_async)
          .with(docx_attachment.file.asset_manager_path, draft: true)

        updater.update!
      end
    end

    context 'when edition has pdf attachment' do
      let(:simple_pdf) { File.open(fixture_path.join('simple.pdf')) }
      let(:pdf_attachment) { FactoryBot.build(:file_attachment, file: simple_pdf) }

      before do
        edition.attachments << pdf_attachment
      end

      it 'updates draft status of asset for attachment' do
        AssetManagerUpdateAssetWorker.expects(:perform_async)
          .with(pdf_attachment.file.asset_manager_path, draft: true)

        updater.update!
      end

      context 'and attachment should be visible, i.e. not draft' do
        let(:visible) { true }

        it 'updates draft status of asset for attachment' do
          AssetManagerUpdateAssetWorker.expects(:perform_async)
            .with(pdf_attachment.file.asset_manager_path, draft: false)

          updater.update!
        end
      end
    end
  end
end
