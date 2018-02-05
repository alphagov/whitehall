require 'test_helper'

class AttachmentDraftStatusTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  context 'when draft document with file attachments is published' do
    test 'attachments & their thumbnails are marked as published in Asset Manager' do
      edition = create(:news_article)
      edition.attachments << FactoryBot.build(
        :file_attachment,
        file: File.open(fixture_path.join('whitepaper.pdf'))
      )
      edition.attachments << FactoryBot.build(
        :file_attachment,
        file: File.open(fixture_path.join('greenpaper.pdf'))
      )
      # ensure CarrierWave uploader returns instance of correct File class
      edition.reload

      Services.asset_manager.stubs(:whitehall_asset)
        .with(regexp_matches(%r{attachment_data/file/\d+/whitepaper\.pdf$}))
        .returns('id' => 'http://asset-manager/assets/asset-1', 'draft' => true)
      Services.asset_manager.stubs(:whitehall_asset)
        .with(regexp_matches(%r{attachment_data/file/\d+/thumbnail_whitepaper\.pdf\.png$}))
        .returns('id' => 'http://asset-manager/assets/asset-2', 'draft' => true)

      Services.asset_manager.stubs(:whitehall_asset)
        .with(regexp_matches(%r{attachment_data/file/\d+/greenpaper\.pdf$}))
        .returns('id' => 'http://asset-manager/assets/asset-3', 'draft' => true)
      Services.asset_manager.stubs(:whitehall_asset)
        .with(regexp_matches(%r{attachment_data/file/\d+/thumbnail_greenpaper\.pdf\.png$}))
        .returns('id' => 'http://asset-manager/assets/asset-4', 'draft' => true)

      Services.asset_manager.expects(:update_asset).with('asset-1', draft: false)
      Services.asset_manager.expects(:update_asset).with('asset-2', draft: false)

      Services.asset_manager.expects(:update_asset).with('asset-3', draft: false)
      Services.asset_manager.expects(:update_asset).with('asset-4', draft: false)

      force_publisher = Whitehall.edition_services.force_publisher(edition)
      assert force_publisher.perform!, force_publisher.failure_reason
    end
  end

  context 'when published document with file attachments is unpublished' do
    test 'attachments & their thumbnails are marked as draft in Asset Manager' do
      edition = create(:published_news_article)
      edition.attachments << FactoryBot.build(
        :file_attachment,
        file: File.open(fixture_path.join('whitepaper.pdf'))
      )
      edition.attachments << FactoryBot.build(
        :file_attachment,
        file: File.open(fixture_path.join('greenpaper.pdf'))
      )
      # ensure CarrierWave uploader returns instance of correct File class
      edition.reload

      Services.asset_manager.stubs(:whitehall_asset)
        .with(regexp_matches(%r{attachment_data/file/\d+/whitepaper\.pdf$}))
        .returns('id' => 'http://asset-manager/assets/asset-1', 'draft' => false)
      Services.asset_manager.stubs(:whitehall_asset)
        .with(regexp_matches(%r{attachment_data/file/\d+/thumbnail_whitepaper\.pdf\.png$}))
        .returns('id' => 'http://asset-manager/assets/asset-2', 'draft' => false)

      Services.asset_manager.stubs(:whitehall_asset)
        .with(regexp_matches(%r{attachment_data/file/\d+/greenpaper\.pdf$}))
        .returns('id' => 'http://asset-manager/assets/asset-3', 'draft' => false)
      Services.asset_manager.stubs(:whitehall_asset)
        .with(regexp_matches(%r{attachment_data/file/\d+/thumbnail_greenpaper\.pdf\.png$}))
        .returns('id' => 'http://asset-manager/assets/asset-4', 'draft' => false)

      Services.asset_manager.expects(:update_asset).with('asset-1', draft: true)
      Services.asset_manager.expects(:update_asset).with('asset-2', draft: true)

      Services.asset_manager.expects(:update_asset).with('asset-3', draft: true)
      Services.asset_manager.expects(:update_asset).with('asset-4', draft: true)

      unpublisher = Whitehall.edition_services.unpublisher(edition, unpublishing: {
        unpublishing_reason: UnpublishingReason::PublishedInError
      })
      assert unpublisher.perform!, unpublisher.failure_reason
    end
  end

  context 'when published document with file attachments is withdrawn' do
    test 'attachments & their thumbnails are not marked as draft in Asset Manager' do
      edition = create(:published_news_article)
      edition.attachments << FactoryBot.build(
        :file_attachment,
        file: File.open(fixture_path.join('whitepaper.pdf'))
      )
      edition.attachments << FactoryBot.build(
        :file_attachment,
        file: File.open(fixture_path.join('greenpaper.pdf'))
      )
      # ensure CarrierWave uploader returns instance of correct File class
      edition.reload

      Services.asset_manager.stubs(:whitehall_asset)
        .with(regexp_matches(%r{attachment_data/file/\d+/whitepaper\.pdf$}))
        .returns('id' => 'http://asset-manager/assets/asset-1', 'draft' => false)
      Services.asset_manager.stubs(:whitehall_asset)
        .with(regexp_matches(%r{attachment_data/file/\d+/thumbnail_whitepaper\.pdf\.png$}))
        .returns('id' => 'http://asset-manager/assets/asset-2', 'draft' => false)

      Services.asset_manager.stubs(:whitehall_asset)
        .with(regexp_matches(%r{attachment_data/file/\d+/greenpaper\.pdf$}))
        .returns('id' => 'http://asset-manager/assets/asset-3', 'draft' => false)
      Services.asset_manager.stubs(:whitehall_asset)
        .with(regexp_matches(%r{attachment_data/file/\d+/thumbnail_greenpaper\.pdf\.png$}))
        .returns('id' => 'http://asset-manager/assets/asset-4', 'draft' => false)

      Services.asset_manager.expects(:update_asset).never

      withdrawer = Whitehall.edition_services.withdrawer(edition, unpublishing: {
        unpublishing_reason: UnpublishingReason::Withdrawn,
        explanation: 'withdrawal-reason'
      })
      assert withdrawer.perform!, withdrawer.failure_reason
    end
  end
end
