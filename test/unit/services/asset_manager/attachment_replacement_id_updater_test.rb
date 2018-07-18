require 'test_helper'

class AssetManager::AttachmentReplacementIdUpdaterTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let(:worker) { AssetManager::AttachmentReplacementIdUpdater }
  let(:update_worker) { mock('asset-manager-update-asset-worker') }

  around do |test|
    AssetManager.stub_const(:AssetUpdater, update_worker) do
      test.call
    end
  end

  context 'when attachment data is not a PDF' do
    let(:sample_rtf) { File.open(fixture_path.join('sample.rtf')) }
    let(:sample_docx) { File.open(fixture_path.join('sample.docx')) }
    let(:attachment_data) { AttachmentData.create!(file: sample_rtf, replaced_by: replacement) }
    let(:replacement) { AttachmentData.create!(file: sample_docx) }
    let(:key) { 'replacement_legacy_url_path' }
    let(:attributes) { { key => replacement.file.asset_manager_path } }

    it 'updates replacement ID of corresponding asset' do
      update_worker.expects(:call)
        .with(attachment_data, attachment_data.file.asset_manager_path, attributes)

      worker.call(attachment_data)
    end
  end

  context 'when attachment does not have a replacement' do
    let(:sample_rtf) { File.open(fixture_path.join('sample.rtf')) }
    let(:attachment_data) { AttachmentData.create!(file: sample_rtf) }

    it 'does not update asset manager' do
      update_worker.expects(:call).never

      worker.call(attachment_data)
    end
  end

  context 'when attachment data is a PDF' do
    let(:simple_pdf) { File.open(fixture_path.join('simple.pdf')) }
    let(:whitepaper_pdf) { File.open(fixture_path.join('whitepaper.pdf')) }
    let(:attachment_data) { AttachmentData.create!(file: simple_pdf, replaced_by: replacement) }
    let(:replacement) { AttachmentData.create!(file: whitepaper_pdf) }
    let(:key) { 'replacement_legacy_url_path' }
    let(:replacement_url_path) { replacement.file.asset_manager_path }
    let(:attributes) { { key => replacement_url_path } }
    let(:replacement_thumbnail_url_path) { replacement.file.thumbnail.asset_manager_path }
    let(:thumbnail_attributes) { { key => replacement_thumbnail_url_path } }

    it 'updates replacement ID of asset for attachment & its thumbnail' do
      update_worker.expects(:call)
        .with(attachment_data, attachment_data.file.asset_manager_path, attributes)
      update_worker.expects(:call)
        .with(attachment_data, attachment_data.file.thumbnail.asset_manager_path, thumbnail_attributes)

      worker.call(attachment_data)
    end

    context 'but replacement is not a PDF' do
      let(:sample_rtf) { File.open(fixture_path.join('sample.rtf')) }
      let(:replacement) { AttachmentData.create!(file: sample_rtf) }
      let(:thumbnail_attributes) { { key => replacement_url_path } }

      it 'updates replacement ID of asset for attachment & its thumbnail' do
        update_worker.expects(:call)
          .with(attachment_data, attachment_data.file.asset_manager_path, attributes)
        update_worker.expects(:call)
          .with(attachment_data, attachment_data.file.thumbnail.asset_manager_path, thumbnail_attributes)

        worker.call(attachment_data)
      end
    end
  end

  context 'when attachment is not synced with asset manager' do
    let(:sample_rtf) { File.open(fixture_path.join('sample.rtf')) }
    let(:sample_docx) { File.open(fixture_path.join('sample.docx')) }
    let(:attachment_data) { AttachmentData.create!(file: sample_rtf, replaced_by: replacement) }
    let(:replacement) { AttachmentData.create!(file: sample_docx) }

    before do
      update_worker.expects(:call)
        .raises(AssetManager::ServiceHelper::AssetNotFound.new('asset not found'))
    end

    it 'raises a AssetNotFound error' do
      assert_raises(AssetManager::ServiceHelper::AssetNotFound) do
        worker.call(attachment_data)
      end
    end
  end
end
