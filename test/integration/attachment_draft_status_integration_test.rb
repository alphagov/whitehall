require 'test_helper'
require 'capybara/rails'

class AttachmentDraftStatusIntegrationTest < ActionDispatch::IntegrationTest
  extend Minitest::Spec::DSL
  include Capybara::DSL
  include Rails.application.routes.url_helpers

  let(:filename) { 'sample.docx' }
  let(:asset_id) { 'asset-id' }

  before do
    login_as create(:managing_editor)
    stub_whitehall_asset(filename, id: asset_id, draft: asset_initially_draft)
  end

  context 'given a file attachment' do
    let(:file) { File.open(path_to_attachment(filename)) }
    let(:attachment) { build(:file_attachment, attachable: attachable, file: file) }
    let(:attachable) { edition }

    before do
      setup_publishing_api_for(edition)
      attachable.attachments << attachment
      VirusScanHelpers.simulate_virus_scan
    end

    context 'on a draft document' do
      let(:edition) { create(:news_article) }
      let(:asset_initially_draft) { true }

      it 'marks attachment as published in Asset Manager when document is published' do
        visit admin_news_article_path(edition)
        force_publish_document
        assert_sets_draft_status_in_asset_manager_to false
      end
    end

    context 'on a published document' do
      let(:edition) { create(:published_news_article) }
      let(:asset_initially_draft) { false }

      it 'does not mark attachment as draft in Asset Manager when document is unpublished' do
        visit admin_news_article_path(edition)
        unpublish_document_published_in_error
        refute_sets_draft_status_in_asset_manager_to true
      end
    end

    context 'on an outcome on a draft consultation' do
      let(:edition) { create(:draft_consultation) }
      let(:outcome_attributes) { FactoryBot.attributes_for(:consultation_outcome) }
      let(:attachable) { edition.create_outcome!(outcome_attributes) }
      let(:asset_initially_draft) { true }

      it 'marks attachment as published in Asset Manager when consultation is published' do
        visit admin_consultation_path(edition)
        force_publish_document
        assert_sets_draft_status_in_asset_manager_to false
      end
    end

    context 'on a feedback on a draft consultation' do
      let(:edition) { create(:draft_consultation) }
      let(:feedback_attributes) { FactoryBot.attributes_for(:consultation_public_feedback) }
      let(:attachable) { edition.create_public_feedback!(feedback_attributes) }
      let(:asset_initially_draft) { true }

      it 'marks attachment as published in Asset Manager when consultation is published' do
        visit admin_consultation_path(edition)
        force_publish_document
        assert_sets_draft_status_in_asset_manager_to false
      end
    end
  end

  context 'given a policy group' do
    let(:policy_group) { create(:policy_group) }
    let(:asset_initially_draft) { true }

    it 'marks attachment as published in Asset Manager when added to policy group' do
      visit admin_policy_group_attachments_path(policy_group)
      add_attachment(filename)
      assert_sets_draft_status_in_asset_manager_to false
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

  def assert_sets_draft_status_in_asset_manager_to(draft, never: false)
    expectation = Services.asset_manager.expects(:update_asset)
      .with(asset_id, 'draft' => draft)
    expectation.never if never
    AssetManagerUpdateAssetWorker.drain
  end

  def refute_sets_draft_status_in_asset_manager_to(draft)
    assert_sets_draft_status_in_asset_manager_to(draft, never: true)
  end

  def force_publish_document
    click_link 'Force publish'
    fill_in 'Reason for force publishing', with: 'testing'
    click_button 'Force publish'
    assert_text %r{The document .* has been published}
  end

  def unpublish_document_published_in_error
    click_link 'Withdraw or unpublish'
    within '#js-published-in-error-form' do
      click_button 'Unpublish'
    end
    assert_text 'This document has been unpublished'
  end

  def add_attachment(filename)
    click_link 'Upload new file attachment'
    fill_in 'Title', with: 'Attachment Title'
    attach_file 'File', path_to_attachment(filename)
    click_button 'Save'
    assert_text "Attachment 'Attachment Title' uploaded"
  end
end
