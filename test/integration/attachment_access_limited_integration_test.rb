require 'test_helper'
require 'capybara/rails'

class AttachmentAccessLimitedIntegrationTest < ActionDispatch::IntegrationTest
  extend Minitest::Spec::DSL
  include Capybara::DSL
  include Rails.application.routes.url_helpers

  let(:organisation) { create(:organisation) }
  let(:managing_editor) { create(:managing_editor, organisation: organisation, uid: 'user-uid') }

  before do
    login_as managing_editor
    publishing_api_has_linkables([], document_type: 'topic')
  end

  context 'given a draft document with file attachment' do
    let(:edition) { create(:news_article, organisations: [organisation]) }

    before do
      setup_publishing_api_for(edition)
      publishing_api_has_linkables([], document_type: 'topic')

      add_file_attachment('logo.png', to: edition)
      VirusScanHelpers.simulate_virus_scan(include_versions: true)
      edition.attachments[0].attachment_data.uploaded_to_asset_manager!
      edition.save!

      stub_whitehall_asset('logo.png', id: 'asset-id', draft: true)
    end

    context 'when document is marked as access limited in Whitehall' do
      before do
        visit edit_admin_news_article_path(edition)
        check 'Limit access to producing organisations prior to publication'
        click_button 'Save'
        assert_text 'The document has been saved'
      end

      it 'marks attachment as access limited in Asset Manager' do
        Services.asset_manager.expects(:update_asset).with('asset-id', 'access_limited' => ['user-uid'])

        AssetManagerAttachmentDataWorker.drain
      end
    end
  end

  context 'given an access-limited draft document' do
    # the edition has to have same organisation as logged in user, otherwise it's not visible when access_limited = true
    let(:edition) { create(:news_article, organisations: [organisation], access_limited: true) }

    before do
      setup_publishing_api_for(edition)

      stub_whitehall_asset('logo.png', id: 'asset-id', draft: true)
    end

    context 'when an attachment is added to the draft document' do
      before do
        visit admin_news_article_path(edition)
        click_link 'Modify attachments'
        click_link 'Upload new file attachment'
        fill_in 'Title', with: 'asset-title'
        attach_file 'File', path_to_attachment('logo.png')
        click_button 'Save'
        assert_text "Attachment 'asset-title' uploaded"
      end

      it 'marks attachment as access limited in Asset Manager' do
        Services.asset_manager.expects(:create_whitehall_asset).with(
          has_entries(
            legacy_url_path: regexp_matches(/logo\.png/),
            access_limited: ['user-uid']
          )
        )
        AssetManagerCreateWhitehallAssetWorker.drain
      end
    end

    context 'when bulk uploaded to draft document' do
      before do
        visit admin_news_article_path(edition)
        click_link 'Modify attachments'
        click_link 'Bulk upload from Zip file'
        attach_file 'Zip file', path_to_attachment('sample_attachment.zip')
        click_button 'Upload zip'
        fill_in 'Title', with: 'file-title'
        click_button 'Save'
        assert find('.existing-attachments a', text: 'greenpaper.pdf')
      end

      it 'marks attachment as access limited in Asset Manager' do
        Services.asset_manager.expects(:create_whitehall_asset).with(
          has_entries(
            legacy_url_path: regexp_matches(/greenpaper\.pdf/),
            access_limited: ['user-uid']
          )
        )
        Services.asset_manager.expects(:create_whitehall_asset).with(
          has_entries(
            legacy_url_path: regexp_matches(/thumbnail_greenpaper\.pdf\.png/),
            access_limited: ['user-uid']
          )
        )

        AssetManagerCreateWhitehallAssetWorker.drain
      end
    end
  end

  context 'given an outcome on an access-limited draft consultation' do
    # the edition has to have same organisation as logged in user, otherwise it's not visible when access_limited = true
    let(:edition) { create(:consultation, organisations: [organisation], access_limited: true) }
    let(:outcome_attributes) { FactoryBot.attributes_for(:consultation_outcome) }
    let!(:outcome) { edition.create_outcome!(outcome_attributes) }

    before do
      setup_publishing_api_for(edition)
      publishing_api_has_linkables([], document_type: 'topic')

      stub_whitehall_asset('logo.png', id: 'asset-id', draft: true)
    end

    context 'when an attachment is added to the outcome' do
      before do
        visit admin_consultation_path(edition)
        click_link 'Edit draft'
        click_link 'Final outcome'
        click_link 'Upload new file attachment'
        fill_in 'Title', with: 'asset-title'
        attach_file 'File', path_to_attachment('logo.png')
        click_button 'Save'
        assert_text "Attachment 'asset-title' uploaded"
      end

      it 'marks attachment as access limited in Asset Manager' do
        Services.asset_manager.expects(:create_whitehall_asset).with(
          has_entries(
            legacy_url_path: regexp_matches(/logo\.png/),
            access_limited: ['user-uid']
          )
        )
        AssetManagerCreateWhitehallAssetWorker.drain
      end
    end
  end

  context 'given an access-limited draft document with file attachment' do
    let(:edition) { create(:news_article, organisations: [organisation], access_limited: true) }

    before do
      setup_publishing_api_for(edition)
      publishing_api_has_linkables([], document_type: 'topic')

      add_file_attachment('logo.png', to: edition)
      VirusScanHelpers.simulate_virus_scan(include_versions: true)
      edition.attachments[0].attachment_data.uploaded_to_asset_manager!

      stub_whitehall_asset('logo.png', id: 'asset-id', draft: true)
    end

    context 'when document is unmarked as access limited in Whitehall' do
      before do
        visit edit_admin_news_article_path(edition)
        uncheck 'Limit access to producing organisations prior to publication'
        click_button 'Save'
        assert_text 'The document has been saved'
      end

      it 'unmarks attachment as access limited in Asset Manager' do
        Services.asset_manager.expects(:update_asset).with('asset-id', 'access_limited' => [])

        AssetManagerAttachmentDataWorker.drain
      end
    end

    context 'when attachment is replaced' do
      before do
        visit admin_news_article_path(edition)
        click_link 'Modify attachments'
        click_link 'Edit'
        attach_file 'Replace file', path_to_attachment('big-cheese.960x640.jpg')
        click_button 'Save'
        assert_text "Attachment 'logo.png' updated"
      end

      it 'marks replacement attachment as access limited in Asset Manager' do
        Services.asset_manager.expects(:create_whitehall_asset).with do |params|
          params[:legacy_url_path] =~ /big-cheese/ &&
            params[:access_limited] == ['user-uid']
        end

        AssetManagerCreateWhitehallAssetWorker.drain
      end
    end
  end

private

  def setup_publishing_api_for(edition)
    publishing_api_has_links(
      content_id: edition.document.content_id,
      links: {}
    )
  end

  def add_file_attachment(filename, to:)
    to.attachments << FactoryBot.build(
      :file_attachment,
      attachable: to,
      title: filename,
      file: File.open(path_to_attachment(filename))
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

  def ends_with(expected)
    ->(actual) { actual.end_with?(expected) }
  end
end
