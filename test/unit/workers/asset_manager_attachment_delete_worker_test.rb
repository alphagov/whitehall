require 'test_helper'

class AssetManagerAttachmentDeleteWorkerTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let(:worker) { AssetManagerAttachmentDeleteWorker.new }
  let(:attachment_data) { nil }
  let(:delete_worker) { mock('delete-worker') }

  before do
    AttachmentData.stubs(:find_by).with(id: id).returns(attachment_data)
  end

  around do |test|
    AssetManager.stub_const(:AssetDeleter, delete_worker) do
      test.call
    end
  end

  context 'when attachment data does not exist' do
    let(:id) { 'no-such-id' }

    it 'does not delete any assets from Asset Manager' do
      delete_worker.expects(:call).never

      worker.perform(id)
    end
  end

  context 'when attachment data exists' do
    let(:attachment_data) { create(:attachment_data, file: file) }
    let(:id) { attachment_data.id }

    before do
      attachment_data.stubs(:deleted?).returns(deleted)
    end

    context 'when attachment data is not a PDF' do
      let(:file) { File.open(fixture_path.join('sample.rtf')) }

      context 'and attachment data is deleted' do
        let(:deleted) { true }

        it 'deletes corresponding asset in Asset Manager' do
          delete_worker.expects(:call)
            .with(attachment_data.file.asset_manager_path)

          worker.perform(id)
        end
      end

      context 'and attachment data is not deleted' do
        let(:deleted) { false }

        it 'does not delete any assets from Asset Manager' do
          delete_worker.expects(:call).never

          assert AssetManagerDeleteAssetWorker.jobs.empty?
        end
      end
    end

    context 'when attachment data is a PDF' do
      let(:file) { File.open(fixture_path.join('simple.pdf')) }

      context 'and attachment data is deleted' do
        let(:deleted) { true }

        it 'deletes attachment & thumbnail asset in Asset Manager' do
          delete_worker.expects(:call)
            .with(attachment_data.file.asset_manager_path)
          delete_worker.expects(:call)
            .with(attachment_data.file.thumbnail.asset_manager_path)

          worker.perform(id)
        end
      end
    end
  end
end
