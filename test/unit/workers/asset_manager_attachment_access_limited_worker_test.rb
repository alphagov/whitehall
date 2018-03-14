require 'test_helper'

class AssetManagerAttachmentAccessLimitedWorkerTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let(:worker) { AssetManagerAttachmentAccessLimitedWorker.new }
  let(:attachment_data) { attachment.attachment_data }
  let(:update_worker) { mock('asset-manager-update-asset-worker') }

  setup do
    AssetManagerUpdateAssetWorker.stubs(:new).returns(update_worker)
  end

  context 'when attachment cannot be found' do
    it 'does not update the access limited state' do
      update_worker.expects(:perform).never

      worker.perform('no-such-id')
    end
  end

  context "when attachment's attachable is access limited and the attachment is not a PDF" do
    let(:sample_rtf) { File.open(fixture_path.join('sample.rtf')) }
    let(:attachment) { FactoryBot.create(:file_attachment, file: sample_rtf) }

    before do
      AttachmentData.stubs(:find_by).with(id: attachment_data.id).returns(attachment_data)

      access_limited_object = stub('access-limited-object')
      AssetManagerAccessLimitation.stubs(:for).with(access_limited_object).returns(['user-uid'])

      attachment_data.stubs(:access_limited?).returns(true)
      attachment_data.stubs(:access_limited_object).returns(access_limited_object)
    end

    it 'updates the access limited state of the asset' do
      update_worker.expects(:perform)
        .with(attachment.file.asset_manager_path, 'access_limited' => ['user-uid'])

      worker.perform(attachment_data.id)
    end
  end

  context "when attachment's attachable is access limited and the attachment is a PDF" do
    let(:simple_pdf) { File.open(fixture_path.join('simple.pdf')) }
    let(:attachment) { FactoryBot.create(:file_attachment, file: simple_pdf) }

    before do
      AttachmentData.stubs(:find_by).with(id: attachment_data.id).returns(attachment_data)

      access_limited_object = stub('access-limited-object')
      AssetManagerAccessLimitation.stubs(:for).with(access_limited_object).returns(['user-uid'])

      attachment_data.stubs(:access_limited?).returns(true)
      attachment_data.stubs(:access_limited_object).returns(access_limited_object)
    end

    it "updates the access limited state of the asset and it's thumbnail" do
      update_worker.expects(:perform)
        .with(attachment.file.asset_manager_path, 'access_limited' => ['user-uid'])
      update_worker.expects(:perform)
        .with(attachment.file.thumbnail.asset_manager_path, 'access_limited' => ['user-uid'])

      worker.perform(attachment_data.id)
    end
  end

  context "when attachment's attachable is not access limited and the attachment is not a PDF" do
    let(:sample_rtf) { File.open(fixture_path.join('sample.rtf')) }
    let(:attachment) { FactoryBot.create(:file_attachment, file: sample_rtf) }

    before do
      attachment_data.stubs(:access_limited?).returns(false)
    end

    it 'updates the asset to have an empty access_limited array' do
      update_worker.expects(:perform)
        .with(attachment.file.asset_manager_path, 'access_limited' => [])

      worker.perform(attachment_data.id)
    end
  end

  context "when attachment's attachable is not access limited and the attachment is a PDF" do
    let(:simple_pdf) { File.open(fixture_path.join('simple.pdf')) }
    let(:attachment) { FactoryBot.create(:file_attachment, file: simple_pdf) }

    before do
      attachment_data.stubs(:access_limited?).returns(false)
    end

    it 'updates the asset to have an empty access_limited array' do
      update_worker.expects(:perform)
        .with(attachment.file.asset_manager_path, 'access_limited' => [])
      update_worker.expects(:perform)
        .with(attachment.file.thumbnail.asset_manager_path, 'access_limited' => [])

      worker.perform(attachment_data.id)
    end
  end
end
