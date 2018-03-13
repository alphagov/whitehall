require 'test_helper'

module ServiceListeners
  class AttachmentRedirectUrlUpdaterTest < ActiveSupport::TestCase
    extend Minitest::Spec::DSL
    include Rails.application.routes.url_helpers
    include PublicDocumentRoutesHelper

    let(:updater) { AttachmentRedirectUrlUpdater.new(attachment_data) }
    let(:attachment_data) { attachment.attachment_data }
    let(:unpublished_edition) { FactoryBot.create(:unpublished_edition) }
    let(:redirect_url) { Whitehall.url_maker.public_document_url(unpublished_edition) }
    let(:unpublished) { true }

    context 'when attachment has no associated attachment data' do
      let(:attachment) { FactoryBot.create(:html_attachment) }

      it 'does not update redirect URL of any assets' do
        AssetManagerUpdateAssetWorker.expects(:perform_async).never

        updater.update!
      end
    end

    context 'when attachment is not a PDF' do
      let(:sample_rtf) { File.open(fixture_path.join('sample.rtf')) }
      let(:attachment) { FactoryBot.create(:file_attachment, file: sample_rtf) }

      before do
        attachment_data.stubs(:unpublished?).returns(unpublished)
        attachment_data.stubs(:unpublished_edition).returns(unpublished_edition)
      end

      it 'updates redirect URL of corresponding asset' do
        AssetManagerUpdateAssetWorker.expects(:perform_async)
          .with(attachment.file.asset_manager_path, redirect_url: redirect_url)

        updater.update!
      end
    end

    context 'when attachment is a PDF' do
      let(:simple_pdf) { File.open(fixture_path.join('simple.pdf')) }
      let(:attachment) { FactoryBot.create(:file_attachment, file: simple_pdf) }

      before do
        attachment_data.stubs(:unpublished?).returns(unpublished)
        attachment_data.stubs(:unpublished_edition).returns(unpublished_edition)
      end

      it 'updates redirect URL of asset for attachment & its thumbnail' do
        AssetManagerUpdateAssetWorker.expects(:perform_async)
          .with(attachment.file.asset_manager_path, redirect_url: redirect_url)
        AssetManagerUpdateAssetWorker.expects(:perform_async)
          .with(attachment.file.thumbnail.asset_manager_path, redirect_url: redirect_url)

        updater.update!
      end

      context 'and attachment is not unpublished' do
        let(:unpublished) { false }
        let(:unpublished_edition) { nil }

        it 'resets redirect URL of asset for attachment & its thumbnail' do
          AssetManagerUpdateAssetWorker.expects(:perform_async)
            .with(attachment.file.asset_manager_path, redirect_url: nil)
          AssetManagerUpdateAssetWorker.expects(:perform_async)
            .with(attachment.file.thumbnail.asset_manager_path, redirect_url: nil)

          updater.update!
        end
      end
    end
  end
end
