require 'test_helper'
require 'capybara/rails'

class AttachmentReplacementIntegrationTest < ActionDispatch::IntegrationTest
  extend Minitest::Spec::DSL
  include Capybara::DSL
  include Rails.application.routes.url_helpers

  context 'given a draft document with a file attachment' do
    let(:managing_editor) { create(:managing_editor) }

    let(:filename) { 'sample.docx' }
    let(:file) { File.open(path_to_attachment(filename)) }
    let(:attachment) { build(:file_attachment, attachable: edition, file: file) }
    let(:asset_id) { 'asset-id' }

    let(:replacement_filename) { 'sample.rtf' }
    let(:replacement_asset_id) { 'replacement-asset-id' }

    let(:edition) { create(:news_article) }

    before do
      login_as(managing_editor)
      edition.attachments << attachment
      setup_publishing_api_for(edition)
      stub_whitehall_asset(filename, id: asset_id)
      VirusScanHelpers.simulate_virus_scan
    end

    context 'when attachment is replaced' do
      before do
        visit admin_news_article_path(edition)
        click_link 'Modify attachments'
        @attachment_url = find('.existing-attachments a', text: filename)[:href]
        within '.existing-attachments' do
          click_link 'Edit'
        end
        fill_in 'Title', with: 'Attachment Title'
        attach_file 'Replace file', path_to_attachment(replacement_filename)
        click_button 'Save'
        assert_text "Attachment 'Attachment Title' updated"

        VirusScanHelpers.simulate_virus_scan
        stub_whitehall_asset(replacement_filename, id: replacement_asset_id)
      end

      it 'redirects requests for attachment to replacement' do
        visit admin_news_article_path(edition)
        click_link 'Modify attachments'
        replacement_url = find('.existing-attachments a', text: replacement_filename)[:href]

        logout

        get @attachment_url
        assert_redirected_to replacement_url
      end

      it 'updates replacement_id for attachment in Asset Manager' do
        Services.asset_manager.expects(:update_asset)
          .with(asset_id, 'replacement_id' => replacement_asset_id)
        AssetManagerAttachmentReplacementIdUpdateWorker.drain
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
