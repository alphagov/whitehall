require 'test_helper'
require 'capybara/rails'

class AttachmentDraftStatusIntegrationTest < ActionDispatch::IntegrationTest
  extend Minitest::Spec::DSL
  include Capybara::DSL
  include Rails.application.routes.url_helpers

  before do
    login_as create(:managing_editor)
  end

  context 'when draft document with file attachment is published' do
    let(:edition) { create(:news_article) }

    before do
      setup_publishing_api_for(edition)

      add_file_attachment('sample.docx', to: edition)
      VirusScanHelpers.simulate_virus_scan

      stub_whitehall_asset('sample.docx', id: 'asset-id', draft: true)
    end

    it 'marks attachment as published in Asset Manager' do
      visit admin_news_article_path(edition)
      click_link 'Force publish'
      fill_in 'Reason for force publishing', with: 'testing'

      Services.asset_manager.expects(:update_asset).with('asset-id', 'draft' => false)

      click_button 'Force publish'
    end
  end

  context 'when published document with file attachment is unpublished' do
    let(:edition) { create(:published_news_article) }

    before do
      setup_publishing_api_for(edition)

      add_file_attachment('sample.docx', to: edition)
      VirusScanHelpers.simulate_virus_scan

      stub_whitehall_asset('sample.docx', id: 'asset-id', draft: false)
    end

    it 'marks attachment as draft in Asset Manager' do
      visit admin_news_article_path(edition)
      click_link 'Withdraw or unpublish'

      Services.asset_manager.expects(:update_asset).with('asset-id', 'draft' => true)

      within '#js-published-in-error-form' do
        click_button 'Unpublish'
      end
    end
  end

  context 'when draft consultation with outcome with file attachment is published' do
    let(:edition) { create(:draft_consultation) }
    let(:outcome_attributes) { FactoryBot.attributes_for(:consultation_outcome) }
    let(:outcome) { edition.create_outcome!(outcome_attributes) }

    before do
      setup_publishing_api_for(edition)

      add_file_attachment('sample.docx', to: outcome)
      VirusScanHelpers.simulate_virus_scan

      stub_whitehall_asset('sample.docx', id: 'asset-id', draft: true)
    end

    it 'marks attachment as published in Asset Manager' do
      visit admin_consultation_path(edition)
      click_link 'Force publish'
      fill_in 'Reason for force publishing', with: 'testing'

      Services.asset_manager.expects(:update_asset).with('asset-id', 'draft' => false)

      click_button 'Force publish'
    end
  end

  context 'when draft consultation with feedback with file attachment is published' do
    let(:edition) { create(:draft_consultation) }
    let(:feedback_attributes) { FactoryBot.attributes_for(:consultation_public_feedback) }
    let(:feedback) { edition.create_public_feedback!(feedback_attributes) }

    before do
      setup_publishing_api_for(edition)

      add_file_attachment('sample.docx', to: feedback)
      VirusScanHelpers.simulate_virus_scan

      stub_whitehall_asset('sample.docx', id: 'asset-id', draft: true)
    end

    it 'marks attachment as published in Asset Manager' do
      visit admin_consultation_path(edition)
      click_link 'Force publish'
      fill_in 'Reason for force publishing', with: 'testing'

      Services.asset_manager.expects(:update_asset).with('asset-id', 'draft' => false)

      click_button 'Force publish'
    end
  end

  context 'when file attachment is added to policy group' do
    let(:policy_group) { create(:policy_group) }

    before do
      stub_whitehall_asset('sample.docx', id: 'asset-id', draft: true)
    end

    it 'marks attachment as published in Asset Manager' do
      visit admin_policy_group_attachments_path(policy_group)
      click_link 'Upload new file attachment'
      fill_in 'Title', with: 'Attachment Title'
      attach_file 'File', path_to_attachment('sample.docx')

      Services.asset_manager.expects(:update_asset).with('asset-id', 'draft' => false)

      click_button 'Save'
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

  def stub_whitehall_asset(filename, id:, draft:)
    Services.asset_manager.stubs(:whitehall_asset)
      .with(&ends_with(filename))
      .returns('id' => "http://asset-manager/assets/#{id}", 'draft' => draft)
  end
end
