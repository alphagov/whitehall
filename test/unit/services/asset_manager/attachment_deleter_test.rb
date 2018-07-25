require 'test_helper'

class AssetManager::AttachmentDeleterTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let(:worker) { AssetManager::AttachmentDeleter }
  let(:attachment_data) { nil }
  let(:delete_worker) { mock('delete-worker') }

  around do |test|
    AssetManager.stub_const(:AssetDeleter, delete_worker) do
      test.call
    end
  end

  context 'when attachment data exists' do
    let(:attachment_data) { create(:attachment_data, file: file) }

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

          worker.call(attachment_data)
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

          worker.call(attachment_data)
        end
      end
    end
  end
end
