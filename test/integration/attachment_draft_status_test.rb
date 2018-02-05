require 'test_helper'

class AttachmentDraftStatusTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  context 'when draft document with file attachment is published' do
    test 'attachment & its thumbnail are marked as published in Asset Manager' do
      edition = create(:news_article, :with_file_attachment)
      # ensure CarrierWave uploader returns instance of correct File class
      edition.reload

      Services.asset_manager.stubs(:whitehall_asset)
        .with(regexp_matches(%r{attachment_data/file/\d+/greenpaper\.pdf$}))
        .returns('id' => 'http://asset-manager/assets/asset-1', 'draft' => true)
      Services.asset_manager.stubs(:whitehall_asset)
        .with(regexp_matches(%r{attachment_data/file/\d+/thumbnail_greenpaper\.pdf\.png$}))
        .returns('id' => 'http://asset-manager/assets/asset-2', 'draft' => true)

      Services.asset_manager.expects(:update_asset)
        .with('asset-1', draft: false)
      Services.asset_manager.expects(:update_asset)
        .with('asset-2', draft: false)

      Whitehall.edition_services.force_publisher(edition).perform!
    end
  end
end
