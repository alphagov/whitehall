require "test_helper"
require "capybara/rails"

class ImageDraftStatusIntegrationTest < ActionDispatch::IntegrationTest
  extend Minitest::Spec::DSL
  include Capybara::DSL
  include Rails.application.routes.url_helpers
  include TaxonomyHelper
  include Admin::EditionRoutesHelper

  describe "image draft status" do
    let(:image) { build(:image) }
    let(:asset_manager_id) { image.image_data.assets.first.asset_manager_id }
    let(:topic_taxon) { build(:taxon_hash) }

    before do
      login_as create(:managing_editor)
      stub_publishing_api_has_linkables([], document_type: "topic")
    end

    context "given an image" do
      let(:attachable) { edition }

      before do
        edition.images << image
        setup_publishing_api_for(edition)
        stub_publishing_api_expanded_links_with_taxons(edition.content_id, [])
        stub_image_assets(image)

        edition.save!
      end

      context "on a draft document" do
        let(:edition) { create(:publication, :with_alternative_format_provider) }
        let(:asset_initially_draft) { true }

        it "marks image as published in Asset Manager when document is published" do
          stub_publishing_api_expanded_links_with_taxons(edition.content_id, [])
          stub_publishing_api_links_with_taxons(edition.content_id, [topic_taxon["content_id"]])

          assert_sets_draft_status_in_asset_manager_to false

          visit admin_edition_path(edition)
          force_publish_document

          PublishAttachmentAssetJob.drain
        end
      end

      context "on a published document" do
        let(:edition) { create(:published_publication, :with_alternative_format_provider) }
        let(:asset_initially_draft) { false }

        it "does not mark image as draft in Asset Manager when document is unpublished" do
          stub_publishing_api_expanded_links_with_taxons(edition.content_id, [])

          visit admin_edition_path(edition)
          unpublish_document_published_in_error
          refute_sets_draft_status_in_asset_manager_to true
        end
      end
    end

  private

    def setup_publishing_api_for(edition)
      stub_publishing_api_has_links({ content_id: edition.document.content_id, links: {} })
    end

    def stub_image_assets(image)
      image.image_data.assets.each { |asset| stub_asset(asset.asset_manager_id) }
    end

    def stub_asset(asset_manger_id, attributes = {})
      url_id = "http://asset-manager/assets/#{asset_manger_id}"
      Services.asset_manager.stubs(:asset)
              .with(asset_manger_id)
              .returns(attributes.merge(id: url_id).stringify_keys)
    end

    def assert_sets_draft_status_in_asset_manager_to(draft, never: false)
      expectation = Services.asset_manager.expects(:update_asset)
                            .with(asset_manager_id, has_entry("draft", draft))
                            .at_least_once
      expectation.never if never
    end

    def refute_sets_draft_status_in_asset_manager_to(draft)
      assert_sets_draft_status_in_asset_manager_to(draft, never: true)
    end

    def force_publish_document
      click_link "Force publish"
      fill_in "Reason for force publishing", with: "testing"
      click_button "Force publish"
      assert_text %r{The document .* has been published}
    end

    def unpublish_document_published_in_error
      click_link "Withdraw or unpublish"
      within ".js-app-view-unpublish-withdraw-form__published-in-error" do
        click_button "Unpublish"
      end
      assert_text "This document has been unpublished"
    end
  end
end
