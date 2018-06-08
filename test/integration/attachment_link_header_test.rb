require 'test_helper'
require 'capybara/rails'

class AttachmentLinkHeaderIntegrationTest < ActionDispatch::IntegrationTest
  extend Minitest::Spec::DSL
  include Capybara::DSL
  include Rails.application.routes.url_helpers
  include PublicDocumentRoutesHelper
  include TaxonomyHelper

  let(:filename) { 'sample.docx' }
  let(:asset_id) { 'asset-id' }

  before do
    login_as create(:managing_editor)
    publishing_api_has_linkables([], document_type: 'topic')
    stub_whitehall_asset(filename, id: asset_id, draft: asset_initially_draft)
  end

  context 'given a file attachment' do
    let(:file) { File.open(path_to_attachment(filename)) }
    let(:attachment) { build(:file_attachment, attachable: attachable, file: file) }
    let(:attachable) { edition }
    let(:topic_taxon) { build(:taxon_hash) }

    before do
      setup_publishing_api_for(edition)
      attachable.attachments << attachment
      attachable.save!
    end

    context 'on a draft document' do
      let(:edition) { create(:news_article) }
      let(:asset_initially_draft) { true }

      it 'sets link to parent document in Asset Manager when document is published' do
        visit admin_news_article_path(edition)
        force_publish_document

        parent_document_url = Whitehall.url_maker.public_document_url(edition)

        Services.asset_manager.expects(:update_asset)
          .at_least_once
          .with(asset_id, has_entry('parent_document_url', parent_document_url))

        AssetManagerAttachmentMetadataWorker.drain
      end
    end
  end

private

  def ends_with(expected)
    ->(actual) { actual.end_with?(expected) }
  end

  def setup_publishing_api_for(edition)
    stub_publishing_api_expanded_links_with_taxons(edition.content_id, [])
    stub_publishing_api_links_with_taxons(edition.content_id, [topic_taxon["content_id"]])
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

  def force_publish_document
    click_link 'Force publish'
    fill_in 'Reason for force publishing', with: 'testing'
    click_button 'Force publish'
    assert_text %r{The document .* has been published}
  end
end
