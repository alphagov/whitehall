require 'test_helper'
require 'capybara/rails'

class AttachmentDraftStatusIntegrationTest < ActionDispatch::IntegrationTest
  extend Minitest::Spec::DSL
  include Capybara::DSL
  include Rails.application.routes.url_helpers

  let(:asset_id) { 'asset-id' }

  before do
    login_as create(:managing_editor)
  end

  context 'given a file attachment' do
    context 'on a draft document' do
      let(:edition) { create(:news_article) }

      before do
        setup_publishing_api_for(edition)

        add_file_attachment('sample.docx', to: edition)
        VirusScanHelpers.simulate_virus_scan

        stub_whitehall_asset('sample.docx', id: asset_id, draft: true)
      end

      it 'marks attachment as published in Asset Manager when document is published' do
        visit admin_news_article_path(edition)
        click_link 'Force publish'
        fill_in 'Reason for force publishing', with: 'testing'
        click_button 'Force publish'
        assert_text "The document #{edition.title} has been published"
        assert_sets_draft_status_in_asset_manager_to false
      end
    end

    context 'on a published document' do
      let(:edition) { create(:published_news_article) }

      before do
        setup_publishing_api_for(edition)

        add_file_attachment('sample.docx', to: edition)
        VirusScanHelpers.simulate_virus_scan

        stub_whitehall_asset('sample.docx', id: asset_id, draft: false)
      end

      it 'does not mark attachment as draft in Asset Manager when document is unpublished' do
        visit admin_news_article_path(edition)
        click_link 'Withdraw or unpublish'
        within '#js-published-in-error-form' do
          click_button 'Unpublish'
        end
        assert_text 'This document has been unpublished'
        refute_sets_draft_status_in_asset_manager_to true
      end
    end

    context 'on an outcome on a draft consultation' do
      let(:edition) { create(:draft_consultation) }
      let(:outcome_attributes) { FactoryBot.attributes_for(:consultation_outcome) }
      let(:outcome) { edition.create_outcome!(outcome_attributes) }

      before do
        setup_publishing_api_for(edition)

        add_file_attachment('sample.docx', to: outcome)
        VirusScanHelpers.simulate_virus_scan

        stub_whitehall_asset('sample.docx', id: asset_id, draft: true)
      end

      it 'marks attachment as published in Asset Manager when consultation is published' do
        visit admin_consultation_path(edition)
        click_link 'Force publish'
        fill_in 'Reason for force publishing', with: 'testing'
        click_button 'Force publish'
        assert_text "The document #{edition.title} has been published"
        assert_sets_draft_status_in_asset_manager_to false
      end
    end

    context 'on a feedback on a draft consultation' do
      let(:edition) { create(:draft_consultation) }
      let(:feedback_attributes) { FactoryBot.attributes_for(:consultation_public_feedback) }
      let(:feedback) { edition.create_public_feedback!(feedback_attributes) }

      before do
        setup_publishing_api_for(edition)

        add_file_attachment('sample.docx', to: feedback)
        VirusScanHelpers.simulate_virus_scan

        stub_whitehall_asset('sample.docx', id: asset_id, draft: true)
      end

      it 'marks attachment as published in Asset Manager when consultation is published' do
        visit admin_consultation_path(edition)
        click_link 'Force publish'
        fill_in 'Reason for force publishing', with: 'testing'
        click_button 'Force publish'
        assert_text "The document #{edition.title} has been published"
        assert_sets_draft_status_in_asset_manager_to false
      end
    end
  end

  context 'given a policy group' do
    let(:policy_group) { create(:policy_group) }

    it 'marks attachment as published in Asset Manager when added to policy group' do
      stub_whitehall_asset('sample.docx', id: asset_id, draft: true)
      visit admin_policy_group_attachments_path(policy_group)
      click_link 'Upload new file attachment'
      fill_in 'Title', with: 'Attachment Title'
      attach_file 'File', path_to_attachment('sample.docx')
      click_button 'Save'
      assert_text "Attachment 'Attachment Title' uploaded"
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

  def add_file_attachment(filename, to:)
    to.attachments << FactoryBot.build(
      :file_attachment,
      attachable: to,
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

  def assert_sets_draft_status_in_asset_manager_to(draft, never: false)
    expectation = Services.asset_manager.expects(:update_asset)
      .with(asset_id, 'draft' => draft)
    expectation.never if never
    AssetManagerUpdateAssetWorker.drain
  end

  def refute_sets_draft_status_in_asset_manager_to(draft)
    assert_sets_draft_status_in_asset_manager_to(draft, never: true)
  end
end
