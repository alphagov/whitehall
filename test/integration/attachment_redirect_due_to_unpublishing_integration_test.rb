require 'test_helper'
require 'capybara/rails'

class AttachmentRedirectDueToUnpublishingIntegrationTest < ActionDispatch::IntegrationTest
  extend Minitest::Spec::DSL
  include Capybara::DSL
  include Rails.application.routes.url_helpers

  let(:filename) { 'sample.docx' }
  let(:file) { File.open(path_to_attachment(filename)) }
  let(:attachment) { build(:file_attachment, attachable: attachable, file: file) }
  let(:attachable) { edition }
  let(:redirect_url) { Whitehall.url_maker.public_document_path(edition) }

  before do
    login_as create(:managing_editor)
    setup_publishing_api_for(edition)
    attachable.attachments << attachment
    VirusScanHelpers.simulate_virus_scan
    stub_whitehall_asset(filename, id: 'asset-id')
  end

  context 'given a published document with file attachment' do
    let(:edition) { create(:published_news_article) }

    it 'redirects attachment requests when document is unpublished' do
      visit admin_news_article_path(edition)
      unpublish_document_published_in_error
      logout
      get attachment.url
      assert_redirected_to redirect_url
    end

    it 'redirects attachment requests when document is consolidated' do
      visit admin_news_article_path(edition)
      consolidate_document
      logout
      get attachment.url
      assert_redirected_to redirect_url
    end

    it 'does not redirect attachment requests when document is withdrawn' do
      visit admin_news_article_path(edition)
      withdraw_document
      logout
      get attachment.url
      assert_response :success
    end
  end

  context 'given a published consultation with outcome with file attachment' do
    let(:edition) { create(:published_consultation) }
    let(:outcome_attributes) { attributes_for(:consultation_outcome) }
    let(:attachable) { edition.create_outcome!(outcome_attributes) }

    # TODO: Remove when bug in AttachmentVisibility#unpublished_edition fixed
    it 'does not redirect attachment requests when document is unpublished' do
    # TODO: Uncomment when bug in AttachmentVisibility#unpublished_edition fixed
    # it 'redirects attachment requests when document is unpublished' do
      visit admin_consultation_path(edition)
      unpublish_document_published_in_error
      logout
      get attachment.url
      # TODO: Remove when bug in AttachmentVisibility#unpublished_edition fixed
      assert_response :not_found
      # TODO: Uncomment when bug in AttachmentVisibility#unpublished_edition fixed
      # assert_redirected_to redirect_url
    end

    it 'does not redirect attachment requests when document is withdrawn' do
      visit admin_consultation_path(edition)
      withdraw_document
      logout
      get attachment.url
      assert_response :success
    end
  end

  context 'given a published consultation with feedback with file attachment' do
    let(:edition) { create(:published_consultation) }
    let(:feedback_attributes) { attributes_for(:consultation_public_feedback) }
    let(:attachable) { edition.create_public_feedback!(feedback_attributes) }

    # TODO: Remove when bug in AttachmentVisibility#unpublished_edition fixed
    it 'does not redirect attachment requests when document is unpublished' do
    # TODO: Uncomment when bug in AttachmentVisibility#unpublished_edition fixed
    # it 'redirects attachment requests when document is unpublished' do
      visit admin_consultation_path(edition)
      unpublish_document_published_in_error
      logout
      get attachment.url
      # TODO: Remove when bug in AttachmentVisibility#unpublished_edition fixed
      assert_response :not_found
      # TODO: Uncomment when bug in AttachmentVisibility#unpublished_edition fixed
      # assert_redirected_to redirect_url
    end

    it 'does not redirect attachment requests when document is withdrawn' do
      visit admin_consultation_path(edition)
      withdraw_document
      logout
      get attachment.url
      assert_response :success
    end
  end

  context 'given an unpublished document with file attachment' do
    let(:edition) { create(:news_article, :unpublished) }

    it 'does not redirect attachment requests when document is published' do
      visit admin_news_article_path(edition)
      force_publish_document
      logout
      get attachment.url
      assert_response :success
    end
  end

  context 'given an unpublished consultation with outcome with file attachment' do
    let(:edition) { create(:consultation, :unpublished) }
    let(:outcome_attributes) { attributes_for(:consultation_outcome) }
    let(:attachable) { edition.create_outcome!(outcome_attributes) }

    it 'does not redirect attachment requests when document is published' do
      visit admin_consultation_path(edition)
      force_publish_document
      logout
      get attachment.url
      assert_response :success
    end
  end

  context 'given a withdrawn document with file attachment' do
    let(:edition) { create(:news_article, :published, :withdrawn) }

    it 'does not redirect attachment requests when document is unwithdrawn' do
      visit admin_news_article_path(edition)
      unwithdraw_document
      logout
      get attachment.url
      assert_response :success
    end
  end

  context 'given a withdrawn consultation with outcome with file attachment' do
    let(:edition) { create(:consultation, :published, :withdrawn) }
    let(:outcome_attributes) { attributes_for(:consultation_outcome) }
    let(:attachable) { edition.create_outcome!(outcome_attributes) }

    it 'does not redirect attachment requests when document is unwithdrawn' do
      visit admin_consultation_path(edition)
      unwithdraw_document
      logout
      get attachment.url
      assert_response :success
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

  def unpublish_document_published_in_error
    click_link 'Withdraw or unpublish'
    within '#js-published-in-error-form' do
      click_button 'Unpublish'
    end
    assert_text 'This document has been unpublished'
  end

  def consolidate_document
    click_link 'Withdraw or unpublish'
    within '#js-consolidated-form' do
      fill_in 'consolidated_alternative_url', with: 'https://www.test.gov.uk/example'
      click_button 'Unpublish'
    end
    assert_text 'This document has been unpublished'
  end

  def withdraw_document
    click_link 'Withdraw or unpublish'
    within '#js-withdraw-form' do
      fill_in 'withdrawal_explanation', with: 'testing'
      click_button 'Withdraw'
    end
    assert_text 'This document has been marked as withdrawn'
  end

  def force_publish_document
    click_link 'Force publish'
    fill_in 'Reason for force publishing', with: 'testing'
    click_button 'Force publish'
    assert_text %r{The document .* has been published}
  end

  def unwithdraw_document
    click_link 'Unwithdraw'
    click_button 'Unwithdraw'
    assert_text 'This document has been unwithdrawn'
  end
end
