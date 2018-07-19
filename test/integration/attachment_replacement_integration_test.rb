require 'test_helper'
require 'capybara/rails'

class AttachmentReplacementIntegrationTest < ActionDispatch::IntegrationTest
  extend Minitest::Spec::DSL
  include Capybara::DSL
  include Rails.application.routes.url_helpers

  let(:managing_editor) { create(:managing_editor) }
  let(:filename) { 'sample.docx' }
  let(:file) { File.open(path_to_attachment(filename)) }
  let(:attachment) { build(:file_attachment, title: 'attachment-title', attachable: edition, file: file) }
  let(:asset_id) { 'asset-id' }

  let(:replacement_filename) { 'sample.rtf' }
  let(:replacement_asset_id) { 'replacement-asset-id' }

  before do
    create(:government)
    login_as(managing_editor)
    edition.attachments << attachment
    publishing_api_has_linkables([], document_type: 'topic')
    setup_publishing_api_for(edition)
    stub_whitehall_asset(filename, id: asset_id)
    VirusScanHelpers.simulate_virus_scan

    asset_host = URI.parse(Plek.new.public_asset_host).host
    host! asset_host
  end

  context 'given a draft document with a file attachment' do
    let(:edition) { create(:news_article) }

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
        Attachment.last.attachment_data.uploaded_to_asset_manager!
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

      # We rely on Asset Manager to do the redirect immediately in this case,
      # because the replacement is visible to the user.
      it 'updates replacement_id for attachment in Asset Manager' do
        Services.asset_manager.expects(:update_asset)
          .at_least_once
          .with(asset_id, 'replacement_id' => replacement_asset_id)
        AssetManagerAttachmentMetadataWorker.drain
      end
    end
  end

  context 'given a published document with file attachment' do
    let(:edition) { create(:published_news_article) }

    context 'when new draft is created and attachment is replaced' do
      before do
        publishing_api_has_linkables([], document_type: 'topic')
        visit admin_news_article_path(edition)
        click_button 'Create new edition to edit'
        click_link 'Attachments 1'
        @attachment_url = find('.existing-attachments a', text: filename)[:href]
        within '.existing-attachments' do
          click_link 'Edit'
        end
        attach_file 'Replace file', path_to_attachment(replacement_filename)
        click_button 'Save'
        assert_text "Attachment 'attachment-title' updated"
        VirusScanHelpers.simulate_virus_scan
        Attachment.last.attachment_data.uploaded_to_asset_manager!
        stub_whitehall_asset(replacement_filename, id: replacement_asset_id)
      end

      it 'does not redirect requests for attachment to replacement' do
        logout

        get @attachment_url
        assert_response :ok
      end

      # We rely on Asset Manager *not* to do the redirect, even though the
      # asset is marked as replaced, because the replacement is not yet
      # visible to the user.
      it 'updates replacement_id for attachment in Asset Manager' do
        Services.asset_manager.expects(:update_asset)
          .at_least_once
          .with(asset_id, 'replacement_id' => replacement_asset_id)
        AssetManagerAttachmentMetadataWorker.drain
      end

      context 'and draft edition is published' do
        before do
          AssetManagerAttachmentMetadataWorker.drain

          click_link 'Document'
          fill_in 'Public change note', with: 'attachment replaced'
          click_button 'Save'
          assert_text 'The document has been saved'

          #'cancel' takes user back to overview edit page
          click_link 'cancel'

          click_link 'Modify attachments'
          @replacement_url = find('.existing-attachments a', text: replacement_filename)[:href]

          visit admin_news_article_path(edition.latest_edition)
          click_link 'Force publish'
          fill_in 'Reason for force publishing', with: 'testing'
          click_button 'Force publish'
          assert_text %r{The document .* has been published}
        end

        it 'redirects requests for attachment to replacement' do
          logout

          get @attachment_url
          assert_redirected_to @replacement_url
        end

        # We rely on Asset Manager to do the redirect setup previously
        # (see above), now that the asset *is* publicly available.
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
