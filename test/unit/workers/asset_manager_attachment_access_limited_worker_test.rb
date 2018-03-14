require 'test_helper'

class AssetManagerAttachmentAccessLimitedWorkerTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let(:worker) { AssetManagerAttachmentAccessLimitedWorker.new }
  let(:attachment_data) { attachment.attachment_data }

  context "when attachment's attachable is access limited and the attachment is not a PDF" do
    let(:sample_rtf) { File.open(fixture_path.join('sample.rtf')) }
    let(:attachment) { FactoryBot.create(:file_attachment, file: sample_rtf) }

    before do
      access_limited_object = stub('access-limited-object')
      AssetManagerAccessLimitation.stubs(:for).with(access_limited_object).returns(['user-uid'])

      attachment_data.stubs(:access_limited?).returns(true)
      attachment_data.stubs(:access_limited_object).returns(access_limited_object)
    end

    it 'updates the access limited state of the asset' do
      AssetManagerUpdateAssetWorker.expects(:perform_async)
        .with(attachment.file.asset_manager_path, access_limited: ['user-uid'])

      worker.perform(attachment_data)
    end
  end

  context "when attachment's attachable is access limited and the attachment is a PDF" do
    let(:simple_pdf) { File.open(fixture_path.join('simple.pdf')) }
    let(:attachment) { FactoryBot.create(:file_attachment, file: simple_pdf) }

    before do
      access_limited_object = stub('access-limited-object')
      AssetManagerAccessLimitation.stubs(:for).with(access_limited_object).returns(['user-uid'])

      attachment_data.stubs(:access_limited?).returns(true)
      attachment_data.stubs(:access_limited_object).returns(access_limited_object)
    end

    it "updates the access limited state of the asset and it's thumbnail" do
      AssetManagerUpdateAssetWorker.expects(:perform_async)
        .with(attachment.file.asset_manager_path, access_limited: ['user-uid'])
      AssetManagerUpdateAssetWorker.expects(:perform_async)
        .with(attachment.file.thumbnail.asset_manager_path, access_limited: ['user-uid'])

      worker.perform(attachment_data)
    end
  end

  context "when attachment's attachable is not access limited and the attachment is not a PDF" do
    let(:sample_rtf) { File.open(fixture_path.join('sample.rtf')) }
    let(:attachment) { FactoryBot.create(:file_attachment, file: sample_rtf) }

    before do
      attachment_data.stubs(:access_limited?).returns(false)
    end

    it 'updates the asset to have an empty access_limited array' do
      AssetManagerUpdateAssetWorker.expects(:perform_async)
        .with(attachment.file.asset_manager_path, access_limited: [])

      worker.perform(attachment_data)
    end
  end

  context "when attachment's attachable is not access limited and the attachment is a PDF" do
    let(:simple_pdf) { File.open(fixture_path.join('simple.pdf')) }
    let(:attachment) { FactoryBot.create(:file_attachment, file: simple_pdf) }

    before do
      attachment_data.stubs(:access_limited?).returns(false)
    end

    it 'updates the asset to have an empty access_limited array' do
      AssetManagerUpdateAssetWorker.expects(:perform_async)
        .with(attachment.file.asset_manager_path, access_limited: [])
      AssetManagerUpdateAssetWorker.expects(:perform_async)
        .with(attachment.file.thumbnail.asset_manager_path, access_limited: [])

      worker.perform(attachment_data)
    end
  end
end
