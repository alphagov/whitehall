require 'test_helper'

module ServiceListeners
  class AttachmentAccessLimitedUpdaterTest < ActiveSupport::TestCase
    extend Minitest::Spec::DSL

    let(:updater) { AttachmentAccessLimitedUpdater.new(attachment, queue: queue) }
    let(:queue) { nil }

    context 'when attachment is not a file attachment' do
      let(:attachment) { FactoryBot.create(:html_attachment) }

      it 'does not update draft status of any assets' do
        AssetManagerUpdateAssetWorker.expects(:perform_async).never

        updater.update!
      end
    end

    context 'when attachment has no associated attachment data' do
      let(:attachment) { FileAttachment.new(attachment_data: nil) }

      it 'does not update draft status of any assets' do
        AssetManagerUpdateAssetWorker.expects(:perform_async).never

        updater.update!
      end
    end

    context "when attachment's attachable is access limited and the attachment is not a PDF" do
      let(:sample_rtf) { File.open(fixture_path.join('sample.rtf')) }
      let(:attachment) { FactoryBot.create(:file_attachment, file: sample_rtf) }

      before do
        access_limited_object = stub('access-limited-object')
        AssetManagerAccessLimitation.stubs(:for).with(access_limited_object).returns(['user-uid'])

        attachment.stubs(:attachable_is_access_limited?).returns(true)
        attachment.stubs(:access_limited_object).returns(access_limited_object)
      end

      it 'updates the access limited state of the asset' do
        AssetManagerUpdateAssetWorker.expects(:perform_async)
          .with(attachment.file.asset_manager_path, access_limited: ['user-uid'])

        updater.update!
      end
    end

    context "when attachment's attachable is access limited and the attachment is a PDF" do
      let(:simple_pdf) { File.open(fixture_path.join('simple.pdf')) }
      let(:attachment) { FactoryBot.create(:file_attachment, file: simple_pdf) }

      before do
        access_limited_object = stub('access-limited-object')
        AssetManagerAccessLimitation.stubs(:for).with(access_limited_object).returns(['user-uid'])

        attachment.stubs(:attachable_is_access_limited?).returns(true)
        attachment.stubs(:access_limited_object).returns(access_limited_object)
      end

      it "updates the access limited state of the asset and it's thumbnail" do
        AssetManagerUpdateAssetWorker.expects(:perform_async)
          .with(attachment.file.asset_manager_path, access_limited: ['user-uid'])
        AssetManagerUpdateAssetWorker.expects(:perform_async)
          .with(attachment.file.thumbnail.asset_manager_path, access_limited: ['user-uid'])

        updater.update!
      end
    end

    context "when attachment's attachable is not access limited and the attachment is not a PDF" do
      let(:sample_rtf) { File.open(fixture_path.join('sample.rtf')) }
      let(:attachment) { FactoryBot.create(:file_attachment, file: sample_rtf) }

      before do
        attachment.stubs(:attachable_is_access_limited?).returns(false)
      end

      it 'updates the asset to have an empty access_limited array' do
        AssetManagerUpdateAssetWorker.expects(:perform_async)
          .with(attachment.file.asset_manager_path, access_limited: [])

        updater.update!
      end
    end

    context "when attachment's attachable is not access limited and the attachment is a PDF" do
      let(:simple_pdf) { File.open(fixture_path.join('simple.pdf')) }
      let(:attachment) { FactoryBot.create(:file_attachment, file: simple_pdf) }

      before do
        attachment.stubs(:attachable_is_access_limited?).returns(false)
      end

      it 'updates the asset to have an empty access_limited array' do
        AssetManagerUpdateAssetWorker.expects(:perform_async)
          .with(attachment.file.asset_manager_path, access_limited: [])
        AssetManagerUpdateAssetWorker.expects(:perform_async)
          .with(attachment.file.thumbnail.asset_manager_path, access_limited: [])

        updater.update!
      end
    end

    context 'when a different queue is specified' do
      let(:queue) { 'alternative-queue' }
      let(:worker) { stub('worker', perform_async: nil) }
      let(:attachment) { FactoryBot.create(:file_attachment) }

      it 'uses that queue' do
        AssetManagerUpdateAssetWorker.expects(:set)
          .with(queue: queue).at_least_once.returns(worker)
        worker.expects(:perform_async)
          .with(attachment.file.asset_manager_path, anything)

        updater.update!
      end
    end
  end
end
