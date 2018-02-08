require 'test_helper'

class AttachmentDraftStatusIntegrationTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  context 'when draft document with file attachment is published' do
    before do
      @edition = create(:news_article)
      @edition.attachments << FactoryBot.build(
        :file_attachment,
        attachable: @edition,
        file: File.open(fixture_path.join('whitepaper.pdf'))
      )

      Services.asset_manager.stubs(:whitehall_asset)
        .with(regexp_matches(%r{whitepaper\.pdf$}))
        .returns('id' => 'http://asset-manager/assets/asset-id', 'draft' => true)
    end

    test 'attachment is marked as published in Asset Manager' do
      Services.asset_manager.expects(:update_asset).with('asset-id', 'draft' => false)

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

      Services.asset_manager.stubs(:whitehall_asset)
        .with(regexp_matches(%r{whitepaper\.pdf$}))
        .returns('id' => 'http://asset-manager/assets/asset-id', 'draft' => false)
    end

    test 'attachment is marked as draft in Asset Manager' do
      Services.asset_manager.expects(:update_asset).with('asset-id', 'draft' =>true)

      unpublisher = Whitehall.edition_services.unpublisher(@edition, unpublishing: {
        unpublishing_reason: UnpublishingReason::PublishedInError
      })
      assert unpublisher.perform!, unpublisher.failure_reason
    end
  end
end
