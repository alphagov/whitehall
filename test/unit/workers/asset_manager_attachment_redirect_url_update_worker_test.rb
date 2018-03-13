require 'test_helper'

class AssetManagerAttachmentRedirectUrlUpdateWorkerTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL
  include Rails.application.routes.url_helpers
  include PublicDocumentRoutesHelper

  let(:worker) { AssetManagerAttachmentRedirectUrlUpdateWorker.new }
  let(:attachment_data) { attachment.attachment_data }
  let(:unpublished_edition) { FactoryBot.create(:unpublished_edition) }
  let(:redirect_url) { Whitehall.url_maker.public_document_url(unpublished_edition) }
  let(:unpublished) { true }
  let(:update_worker) { mock('asset-manager-update-asset-worker') }

  setup do
    AssetManagerUpdateAssetWorker.stubs(:new).returns(update_worker)
  end

  context 'when attachment cannot be found' do
    it 'does not update the redirect URL' do
      update_worker.expects(:perform).never

      worker.perform('no-such-id')
    end
  end

  context 'when attachment is not a PDF' do
    let(:sample_rtf) { File.open(fixture_path.join('sample.rtf')) }
    let(:attachment) { FactoryBot.create(:file_attachment, file: sample_rtf) }

    before do
      attachment_data.stubs(:unpublished?).returns(unpublished)
      attachment_data.stubs(:unpublished_edition).returns(unpublished_edition)
      AttachmentData.stubs(:find_by).with(id: attachment_data.id).returns(attachment_data)
    end

    it 'updates redirect URL of corresponding asset' do
      update_worker.expects(:perform)
        .with(attachment.file.asset_manager_path, 'redirect_url' => redirect_url)

      worker.perform(attachment_data.id)
    end
  end

  context 'when attachment is a PDF' do
    let(:simple_pdf) { File.open(fixture_path.join('simple.pdf')) }
    let(:attachment) { FactoryBot.create(:file_attachment, file: simple_pdf) }

    before do
      attachment_data.stubs(:unpublished?).returns(unpublished)
      attachment_data.stubs(:unpublished_edition).returns(unpublished_edition)
      AttachmentData.stubs(:find_by).with(id: attachment_data.id).returns(attachment_data)
    end

    it 'updates redirect URL of asset for attachment & its thumbnail' do
      update_worker.expects(:perform)
        .with(attachment.file.asset_manager_path, 'redirect_url' => redirect_url)
      update_worker.expects(:perform)
        .with(attachment.file.thumbnail.asset_manager_path, 'redirect_url' => redirect_url)

      worker.perform(attachment_data.id)
    end

    context 'and attachment is not unpublished' do
      let(:unpublished) { false }
      let(:unpublished_edition) { nil }

      it 'resets redirect URL of asset for attachment & its thumbnail' do
        update_worker.expects(:perform)
          .with(attachment.file.asset_manager_path, 'redirect_url' => nil)
        update_worker.expects(:perform)
          .with(attachment.file.thumbnail.asset_manager_path, 'redirect_url' => nil)

        worker.perform(attachment_data.id)
      end
    end
  end
end
