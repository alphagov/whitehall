require 'test_helper'

module ServiceListeners
  class AttachmentDraftStatusUpdaterTest < ActiveSupport::TestCase
    extend Minitest::Spec::DSL

    let(:updater) { AttachmentDraftStatusUpdater.new(attachment_data) }
    let(:attachment_data) { attachment.attachment_data }
    let(:visibility) {
      stub(
        'visibility',
        visible?: visible,
        unpublished_edition: unpublished_edition
      )
    }
    let(:visible) { false }
    let(:unpublished_edition) { nil }

    before do
      AttachmentVisibility.stubs(:new).returns(visibility)
    end

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

      it 'marks corresponding asset as draft' do
        AssetManagerUpdateAssetWorker.expects(:perform_async)
          .with(attachment.file.asset_manager_path, draft: true)

        updater.update!
      end

      context 'and queue is specified' do
        let(:queue) { 'alternative_queue' }
        let(:updater) { AttachmentDraftStatusUpdater.new(attachment_data, queue: queue) }
        let(:worker) { stub('worker') }

        it 'marks corresponding asset as draft using specified queue' do
          AssetManagerUpdateAssetWorker.expects(:set)
            .with(queue: queue).returns(worker)
          worker.expects(:perform_async)
            .with(attachment.file.asset_manager_path, draft: true)

          updater.update!
        end
      end
    end

    context 'when attachment is a PDF' do
      let(:simple_pdf) { File.open(fixture_path.join('simple.pdf')) }
      let(:attachment) { FactoryBot.create(:file_attachment, file: simple_pdf) }

      it 'marks asset for attachment & its thumbnail as draft' do
        AssetManagerUpdateAssetWorker.expects(:perform_async)
          .with(attachment.file.asset_manager_path, draft: true)
        AssetManagerUpdateAssetWorker.expects(:perform_async)
          .with(attachment.file.thumbnail.asset_manager_path, draft: true)

        updater.update!
      end

      context 'and attachment should be visible, i.e. not draft' do
        let(:visible) { true }

        it 'marks corresponding assets as not draft' do
          AssetManagerUpdateAssetWorker.expects(:perform_async)
            .with(attachment.file.asset_manager_path, draft: false)
          AssetManagerUpdateAssetWorker.expects(:perform_async)
            .with(attachment.file.thumbnail.asset_manager_path, draft: false)

          updater.update!
        end

        context 'and attachment is associated with an unpublished edition' do
          let(:unpublished_edition) { FactoryBot.create(:unpublished_edition) }

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
end
