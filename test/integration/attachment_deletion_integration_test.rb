require 'test_helper'
require 'capybara/rails'

class AttachmentDeletionIntegrationTest < ActionDispatch::IntegrationTest
  extend Minitest::Spec::DSL
  include Capybara::DSL
  include Rails.application.routes.url_helpers

  context 'given a draft document with a file attachment' do
    let(:managing_editor) { create(:managing_editor) }

    let(:filename) { 'sample.docx' }
    let(:file) { File.open(path_to_attachment(filename)) }
    let(:attachment) { build(:file_attachment, attachable: edition, file: file) }
    let(:asset_id) { 'asset-id' }

    let(:edition) { create(:news_article) }

    before do
      login_as(managing_editor)
      edition.attachments << attachment
      setup_publishing_api_for(edition)
      stub_whitehall_asset(filename, id: asset_id)
      VirusScanHelpers.simulate_virus_scan

      visit admin_news_article_path(edition)
      click_link 'Modify attachments'
      @attachment_url = find('.existing-attachments a', text: filename)[:href]
    end

    context 'when attachment is deleted' do
      before do
        visit admin_news_article_path(edition)
        click_link 'Modify attachments'
        within '.existing-attachments' do
          click_link 'Delete'
        end
        assert_text 'Attachment deleted'
      end

      it 'responds with 404 Not Found for attachment URL' do
        logout

        assert_raises(ActiveRecord::RecordNotFound) do
          get @attachment_url
        end
      end

      it 'deletes attachment in Asset Manager' do
        Services.asset_manager.expects(:delete_asset)
          .with(asset_id)
        AssetManagerDeleteAssetWorker.drain
      end
    end
  end

private

  def ends_with(expected)
    ->(actual) { actual.end_with?(expected) }
  end

  def setup_publishing_api_for(edition)
    publishing_api_has_links(
      content_id: edition.document.content_id,
      links: {}
    )
  end

  def path_to_attachment(filename)
    fixture_path.join(filename)
  end

  def stub_whitehall_asset(filename, attributes = {})
    url_id = "http://asset-manager/assets/#{attributes[:id]}"
    Services.asset_manager.stubs(:whitehall_asset)
      .with(&ends_with(filename))
      .returns(attributes.merge(id: url_id).stringify_keys)
  end
end
