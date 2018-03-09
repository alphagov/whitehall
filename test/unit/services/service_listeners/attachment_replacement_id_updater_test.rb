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

    context 'when attachment data is not a PDF' do
      let(:sample_rtf) { File.open(fixture_path.join('sample.rtf')) }
      let(:sample_docx) { File.open(fixture_path.join('sample.docx')) }
      let(:attachment_data) { AttachmentData.create!(file: sample_rtf, replaced_by: replacement) }
      let(:replacement) { AttachmentData.create!(file: sample_docx) }
      let(:key) { :replacement_legacy_url_path }
      let(:attributes) { { key => replacement.file.asset_manager_path } }

      it 'updates replacement ID of corresponding asset' do
        AssetManagerUpdateAssetWorker.expects(:perform_async)
          .with(attachment_data.file.asset_manager_path, attributes)

        updater.update!
      end

      context 'and queue is specified' do
        let(:queue) { 'alternative_queue' }
        let(:updater) { AttachmentReplacementIdUpdater.new(attachment_data, queue: queue) }

        it 'updates replacement ID of corresponding asset using specified queue' do
          AssetManagerUpdateAssetWorker.expects(:set)
            .with(queue: queue)
          AssetManagerUpdateAssetWorker.expects(:perform_async)
            .with(attachment_data.file.asset_manager_path, attributes)

          updater.update!
        end
      end
    end

    context 'when attachment data is a PDF' do
      let(:simple_pdf) { File.open(fixture_path.join('simple.pdf')) }
      let(:whitepaper_pdf) { File.open(fixture_path.join('whitepaper.pdf')) }
      let(:attachment_data) { AttachmentData.create!(file: simple_pdf, replaced_by: replacement) }
      let(:replacement) { AttachmentData.create!(file: whitepaper_pdf) }
      let(:key) { :replacement_legacy_url_path }
      let(:replacement_url_path) { replacement.file.asset_manager_path }
      let(:attributes) { { key => replacement_url_path } }
      let(:replacement_thumbnail_url_path) { replacement.file.thumbnail.asset_manager_path }
      let(:thumbnail_attributes) { { key => replacement_thumbnail_url_path } }

      it 'updates replacement ID of asset for attachment & its thumbnail' do
        AssetManagerUpdateAssetWorker.expects(:perform_async)
          .with(attachment_data.file.asset_manager_path, attributes)
        AssetManagerUpdateAssetWorker.expects(:perform_async)
          .with(attachment_data.file.thumbnail.asset_manager_path, thumbnail_attributes)

        updater.update!
      end

      context 'but replacement is not a PDF' do
        let(:sample_rtf) { File.open(fixture_path.join('sample.rtf')) }
        let(:replacement) { AttachmentData.create!(file: sample_rtf) }
        let(:thumbnail_attributes) { { key => replacement_url_path } }

        it 'updates replacement ID of asset for attachment & its thumbnail' do
          AssetManagerUpdateAssetWorker.expects(:perform_async)
            .with(attachment_data.file.asset_manager_path, attributes)
          AssetManagerUpdateAssetWorker.expects(:perform_async)
            .with(attachment_data.file.thumbnail.asset_manager_path, thumbnail_attributes)

          updater.update!
        end
      end
    end
  end
end
