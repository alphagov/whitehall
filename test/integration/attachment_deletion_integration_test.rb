require "test_helper"
require "capybara/rails"

class AttachmentDeletionIntegrationTest < ActionDispatch::IntegrationTest
  extend Minitest::Spec::DSL
  include Capybara::DSL
  include Rails.application.routes.url_helpers
  include TaxonomyHelper

  describe "attachment deletion" do
    context "given a draft document with multiple file attachments" do
      let(:managing_editor) { create(:managing_editor) }
      let(:first_attachment) { build(:file_attachment_with_asset, attachable: edition, title: "first attachment") }
      let(:first_asset_id) { "asset_manager_id" }
      let(:second_attachment) { build(:file_attachment, attachable: edition) }
      let(:second_asset_id_original) { "asset_manager_id_original" }
      let(:second_asset_id_thumbnail) { "asset_manager_id_thumbnail" }
      let(:edition) { create(:news_article) }

      before do
        login_as(managing_editor)

        setup_publishing_api_for(edition)
        stub_publishing_api_has_linkables([], document_type: "topic")
        stub_publishing_api_expanded_links_with_taxons(edition.content_id, [])

        stub_asset(first_asset_id)
        stub_asset(second_asset_id_original)
        stub_asset(second_asset_id_thumbnail)

        edition.attachments << [first_attachment, second_attachment]
        edition.save!
      end

      context "when one attachment is deleted" do
        before do
          visit admin_news_article_path(edition)
          click_link "Modify attachments"
          within page.find("li", text: first_attachment.title) do
            click_link "Delete attachment"
          end
          click_button "Delete attachment"
          assert_text "Attachment deleted"
        end

        it "deletes the corresponding asset in Asset Manager" do
          Services.asset_manager.expects(:delete_asset).once.with(first_asset_id)
          assert_equal AssetManagerAttachmentMetadataWorker.jobs.count, 1

          AssetManagerAttachmentMetadataWorker.drain
        end

        it "queues one worker to delete the asset" do
          queued_ids = AssetManagerAttachmentMetadataWorker.jobs.map { |job| job["args"].first }

          assert_equal queued_ids, [first_attachment.attachment_data.id]
        end
      end

      context "when draft document is discarded" do
        before do
          visit admin_news_article_path(edition)
          click_link "Delete draft"
          click_button "Delete"
        end

        it "deletes all corresponding assets in Asset Manager" do
          Services.asset_manager.expects(:delete_asset).once.with(first_asset_id)
          Services.asset_manager.expects(:delete_asset).once.with(second_asset_id_original)
          Services.asset_manager.expects(:delete_asset).once.with(second_asset_id_thumbnail)
          assert_equal AssetManagerAttachmentMetadataWorker.jobs.count, 2

          AssetManagerAttachmentMetadataWorker.drain
        end
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
  end
end
