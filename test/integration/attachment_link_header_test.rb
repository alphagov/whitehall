require "test_helper"
require "capybara/rails"

class AttachmentLinkHeaderIntegrationTest < ActionDispatch::IntegrationTest
  extend Minitest::Spec::DSL
  include Capybara::DSL
  include Rails.application.routes.url_helpers
  include TaxonomyHelper

  describe "attachment link header" do
    let(:asset_manager_id) { "asset_manager_id" }

    before do
      login_as create(:managing_editor)
      setup_publishing_api_for(edition)
      stub_publishing_api_has_linkables([], document_type: "topic")
      stub_asset(asset_manager_id, draft: asset_initially_draft)
    end

    context "given a file attachment" do
      let(:attachable) { edition }
      let(:topic_taxon) { build(:taxon_hash) }

      before do
        attachable.attachments << build(:file_attachment, attachable:)
        attachable.save!
      end

      context "on a draft document" do
        let(:edition) { create(:news_article) }
        let(:asset_initially_draft) { true }

        it "sets link to parent document in Asset Manager when document is published" do
          parent_document_url = edition.public_url
          Services.asset_manager.expects(:update_asset)
                  .at_least_once
                  .with(asset_manager_id, has_entry("parent_document_url", parent_document_url))

          visit admin_news_article_path(edition)
          force_publish_document

          PublishAttachmentAssetJob.drain
        end
      end
    end

  private

    def setup_publishing_api_for(edition)
      stub_publishing_api_expanded_links_with_taxons(edition.content_id, [])
      stub_publishing_api_links_with_taxons(edition.content_id, [topic_taxon["content_id"]])
    end

    def stub_asset(asset_manger_id, attributes = {})
      url_id = "http://asset-manager/assets/#{asset_manger_id}"
      Services.asset_manager.stubs(:asset)
              .with(asset_manger_id)
              .returns(attributes.merge(id: url_id).stringify_keys)
    end

    def force_publish_document
      click_link "Force publish"
      fill_in "Reason for force publishing", with: "testing"
      click_button "Force publish"
      assert_text %r{The document .* has been published}
    end
  end
end
