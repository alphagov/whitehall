require "test_helper"
require "capybara/rails"

class AttachmentDraftStatusIntegrationTest < ActionDispatch::IntegrationTest
  extend Minitest::Spec::DSL
  include Capybara::DSL
  include Rails.application.routes.url_helpers
  include TaxonomyHelper

  describe "attachment draft status" do
    let(:filename) { "sample.docx" }
    let(:asset_manager_id) { "asset_manager_id" }
    let(:topic_taxon) { build(:taxon_hash) }

    before do
      login_as create(:managing_editor)
      stub_publishing_api_has_linkables([], document_type: "topic")
      stub_asset(asset_manager_id, draft: asset_initially_draft)
    end

    context "given a file attachment" do
      let(:attachable) { edition }

      before do
        setup_publishing_api_for(edition)
        attachable.attachments << build(:file_attachment, attachable:)
        attachable.save!
      end

      context "on a draft document" do
        let(:edition) { create(:news_article) }
        let(:asset_initially_draft) { true }

        it "marks attachment as published in Asset Manager when document is published" do
          stub_publishing_api_expanded_links_with_taxons(edition.content_id, [])
          stub_publishing_api_links_with_taxons(edition.content_id, [topic_taxon["content_id"]])

          assert_sets_draft_status_in_asset_manager_to false

          visit admin_news_article_path(edition)
          force_publish_document

          PublishAttachmentAssetJob.drain
        end
      end

      context "on a published document" do
        let(:edition) { create(:published_news_article) }
        let(:asset_initially_draft) { false }

        it "does not mark attachment as draft in Asset Manager when document is unpublished" do
          stub_publishing_api_expanded_links_with_taxons(edition.content_id, [])

          visit admin_news_article_path(edition)
          unpublish_document_published_in_error
          refute_sets_draft_status_in_asset_manager_to true
        end
      end

      context "on an outcome on a draft consultation" do
        let(:edition) { create(:draft_consultation) }
        let(:outcome_attributes) { FactoryBot.attributes_for(:consultation_outcome) }
        let(:attachable) { edition.create_outcome!(outcome_attributes) }
        let(:asset_initially_draft) { true }

        it "marks attachment as published in Asset Manager when consultation is published" do
          stub_publishing_api_expanded_links_with_taxons(edition.content_id, [])
          stub_publishing_api_links_with_taxons(edition.content_id, [topic_taxon["content_id"]])

          assert_sets_draft_status_in_asset_manager_to false

          visit admin_consultation_path(edition)
          force_publish_document

          PublishAttachmentAssetJob.drain
        end
      end

      context "on a feedback on a draft consultation" do
        let(:edition) { create(:draft_consultation) }
        let(:feedback_attributes) { FactoryBot.attributes_for(:consultation_public_feedback) }
        let(:attachable) { edition.create_public_feedback!(feedback_attributes) }
        let(:asset_initially_draft) { true }

        it "marks attachment as published in Asset Manager when consultation is published" do
          stub_publishing_api_expanded_links_with_taxons(edition.content_id, [])
          stub_publishing_api_links_with_taxons(edition.content_id, [topic_taxon["content_id"]])

          assert_sets_draft_status_in_asset_manager_to false

          visit admin_consultation_path(edition)
          force_publish_document

          PublishAttachmentAssetJob.drain
        end
      end
    end

    context "given a policy group" do
      let(:policy_group) { create(:policy_group) }
      let(:asset_initially_draft) { true }

      before do
        stub_create_asset(asset_manager_id)
      end

      it "marks attachment as published in Asset Manager when added to policy group" do
        visit admin_policy_group_attachments_path(policy_group)
        add_attachment(filename)

        AssetManagerCreateAssetWorker.drain

        assert_sets_draft_status_in_asset_manager_to false
        AssetManagerAttachmentMetadataWorker.drain
      end
    end

  private

    def setup_publishing_api_for(edition)
      stub_publishing_api_has_links({ content_id: edition.document.content_id, links: {} })
    end

    def path_to_attachment(filename)
      fixture_path.join(filename)
    end

    def stub_asset(asset_manger_id, attributes = {})
      url_id = "http://asset-manager/assets/#{asset_manger_id}"
      Services.asset_manager.stubs(:asset)
              .with(asset_manger_id)
              .returns(attributes.merge(id: url_id).stringify_keys)
    end

    def stub_create_asset(asset_manger_id)
      url_id = "http://asset-manager/assets/#{asset_manger_id}"
      Services.asset_manager.stubs(:create_asset)
              .returns("id" => url_id, "name" => "filename.pdf")
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

    def add_attachment(filename)
      page.attach_file path_to_attachment(filename)
      click_button "Upload"
      fill_in "Title", with: "Attachment Title"
      click_button "Save"
      assert_text "Attachment 'Attachment Title' uploaded"
    end
  end
end
