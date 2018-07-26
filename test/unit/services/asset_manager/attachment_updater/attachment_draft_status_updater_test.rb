require 'test_helper'

class AssetManager::AttachmentDraftStatusUpdaterTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let(:updater) { AssetManager::AttachmentUpdater }
  let(:attachment_data) { attachment.attachment_data }
  let(:update_worker) { mock('asset-manager-update-asset-worker') }

  around do |test|
    AssetManager.stub_const(:AssetUpdater, update_worker) do
      test.call
    end
  end

  context 'when attachment is not a PDF' do
    let(:sample_rtf) { File.open(fixture_path.join('sample.rtf')) }
    let(:attachment) { FactoryBot.create(:file_attachment, file: sample_rtf) }
    let(:draft) { true }

    before do
      AttachmentData.stubs(:find_by).with(id: attachment.id).returns(attachment_data)
      attachment_data.stubs(:draft?).returns(draft)
    end

    it 'marks corresponding asset as draft' do
      update_worker.expects(:call)
        .with(attachment_data, attachment.file.asset_manager_path, 'draft' => true)

      updater.call(attachment_data, draft_status: true)
    end
  end

  context 'when attachment is a PDF' do
    let(:simple_pdf) { File.open(fixture_path.join('simple.pdf')) }
    let(:attachment) { FactoryBot.create(:file_attachment, file: simple_pdf) }
    let(:draft) { true }
    let(:unpublished) { false }
    let(:replaced) { false }

    before do
      AttachmentData.stubs(:find_by).with(id: attachment.id).returns(attachment_data)
      attachment_data.stubs(:draft?).returns(draft)
      attachment_data.stubs(:unpublished?).returns(unpublished)
      attachment_data.stubs(:replaced?).returns(replaced)
    end

    it 'marks asset for attachment & its thumbnail as draft' do
      update_worker.expects(:call)
        .with(attachment_data, attachment.file.asset_manager_path, 'draft' => true)
      update_worker.expects(:call)
        .with(attachment_data, attachment.file.thumbnail.asset_manager_path, 'draft' => true)

      updater.call(attachment_data, draft_status: true)
    end

    context 'and attachment is not draft' do
      let(:draft) { false }

      it 'marks corresponding assets as not draft' do
        update_worker.expects(:call)
          .with(attachment_data, attachment.file.asset_manager_path, 'draft' => false)
        update_worker.expects(:call)
          .with(attachment_data, attachment.file.thumbnail.asset_manager_path, 'draft' => false)

        updater.call(attachment_data, draft_status: true)
      end
    end

    context 'and attachment is unpublished' do
      let(:unpublished) { true }

      it 'marks corresponding assets as not draft even though attachment is draft' do
        attachment_data.update_attribute(:present_at_unpublish, true)
        update_worker.expects(:call)
          .with(attachment_data, attachment.file.asset_manager_path, 'draft' => false)
        update_worker.expects(:call)
          .with(attachment_data, attachment.file.thumbnail.asset_manager_path, 'draft' => false)

        updater.call(attachment_data, draft_status: true)
      end
    end

    context 'and attachment is replaced' do
      let(:replaced) { true }

      it 'marks corresponding assets as not draft even though attachment is draft' do
        update_worker.expects(:call)
          .with(attachment_data, attachment.file.asset_manager_path, 'draft' => false)
        update_worker.expects(:call)
          .with(attachment_data, attachment.file.thumbnail.asset_manager_path, 'draft' => false)

        updater.call(attachment_data, draft_status: true)
      end
    end
  end
end
