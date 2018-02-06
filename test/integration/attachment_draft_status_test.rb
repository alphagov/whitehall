require 'test_helper'

class AttachmentDraftStatusTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  context 'when draft document with file attachment is published' do
    before do
      @edition = create(:news_article)
      @edition.attachments << FactoryBot.build(
        :file_attachment,
        attachable: @edition,
        file: File.open(fixture_path.join('whitepaper.pdf'))
      )
      # ensure CarrierWave uploader returns instance of correct File class
      @edition.reload

      Services.asset_manager.stubs(:whitehall_asset)
        .with(regexp_matches(%r{whitepaper\.pdf$}))
        .returns('id' => 'http://asset-manager/assets/asset-1', 'draft' => true)
      Services.asset_manager.stubs(:whitehall_asset)
        .with(regexp_matches(%r{thumbnail_whitepaper\.pdf\.png$}))
        .returns('id' => 'http://asset-manager/assets/asset-2', 'draft' => true)
    end

    test 'attachment & its thumbnail are marked as published in Asset Manager' do
      Services.asset_manager.expects(:update_asset).with('asset-1', draft: false)
      Services.asset_manager.expects(:update_asset).with('asset-2', draft: false)

      force_publisher = Whitehall.edition_services.force_publisher(@edition)
      assert force_publisher.perform!, force_publisher.failure_reason
    end
  end

  context 'when published document with file attachment is unpublished' do
    before do
      @edition = create(:published_news_article)
      @edition.attachments << FactoryBot.build(
        :file_attachment,
        attachable: @edition,
        file: File.open(fixture_path.join('whitepaper.pdf'))
      )
      # ensure CarrierWave uploader returns instance of correct File class
      @edition.reload

      Services.asset_manager.stubs(:whitehall_asset)
        .with(regexp_matches(%r{whitepaper\.pdf$}))
        .returns('id' => 'http://asset-manager/assets/asset-1', 'draft' => false)
      Services.asset_manager.stubs(:whitehall_asset)
        .with(regexp_matches(%r{thumbnail_whitepaper\.pdf\.png$}))
        .returns('id' => 'http://asset-manager/assets/asset-2', 'draft' => false)
    end

    test 'attachment & its thumbnail are marked as draft in Asset Manager' do
      Services.asset_manager.expects(:update_asset).with('asset-1', draft: true)
      Services.asset_manager.expects(:update_asset).with('asset-2', draft: true)

      unpublisher = Whitehall.edition_services.unpublisher(@edition, unpublishing: {
        unpublishing_reason: UnpublishingReason::PublishedInError
      })
      assert unpublisher.perform!, unpublisher.failure_reason
    end
  end
end
