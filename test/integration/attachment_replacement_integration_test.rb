require "test_helper"
require "capybara/rails"

class AttachmentReplacementIntegrationTest < ActionDispatch::IntegrationTest
  extend Minitest::Spec::DSL
  include Capybara::DSL
  include Rails.application.routes.url_helpers
  include TaxonomyHelper

  describe "attachment replacement" do
    let(:managing_editor) { create(:managing_editor) }
    let(:filename) { "sample.docx" }
    let(:asset_manager_id) { "asset_manager_id" }
    let(:replacement_filename) { "sample.rtf" }
    let(:replacement_asset_manager_id) { "replacement-asset-id" }
    let(:variant) { Asset.variants[:original] }
    let(:attachment) { build(:file_attachment_with_asset, title: "attachment-title", attachable: edition) }

    before do
      login_as(managing_editor)
      edition.attachments << attachment

      setup_publishing_api_for(edition)
      stub_publishing_api_has_linkables([], document_type: "topic")
      stub_publishing_api_expanded_links_with_taxons(edition.content_id, [])

      stub_asset(asset_manager_id)
      stub_asset(replacement_asset_manager_id)
      stub_create_asset(replacement_asset_manager_id)
    end

    context "given a draft document with a file attachment" do
      let(:edition) { create(:news_article) }

      context "when attachment is replaced" do
        before do
          Sidekiq::Worker.clear_all

          visit admin_news_article_path(edition)
          click_link "Modify attachments"
          within page.find("li", text: filename) do
            click_link "Edit attachment"
          end
          fill_in "Title", with: "Attachment Title"
          attach_file "Replace file", path_to_attachment(replacement_filename)
          click_button "Save"
          assert_text "Attachment 'Attachment Title' updated"
        end

        # We rely on Asset Manager to do the redirect immediately in this case,
        # because the replacement is visible to the user.
        it "updates replacement_id for attachment in Asset Manager" do
          Services.asset_manager.expects(:update_asset)
                  .at_least_once
                  .with(asset_manager_id, { "replacement_id" => replacement_asset_manager_id })

          AssetManagerCreateAttachmentAssetWorker.drain
          PublishingApiDraftUpdateWorker.drain
          AssetManagerAttachmentMetadataWorker.drain
        end
      end
    end

    context "given a published document with file attachment" do
      let(:edition) { create(:published_news_article) }

      context "when new draft is created and attachment is replaced" do
        before do
          Sidekiq::Worker.clear_all

          visit admin_news_article_path(edition)
          click_button "Create new edition"
          click_link "Attachments 1"
          within page.find("li", text: filename) do
            click_link "Edit attachment"
          end
          attach_file "Replace file", path_to_attachment(replacement_filename)
          click_button "Save"
          assert_text "Attachment 'attachment-title' updated"
        end

        # We rely on Asset Manager *not* to do the redirect, even though the
        # asset is marked as replaced, because the replacement is not yet
        # visible to the user.
        it "updates replacement_id for attachment in Asset Manager" do
          AssetManagerCreateAttachmentAssetWorker.drain

          Services.asset_manager.expects(:update_asset)
                  .at_least_once
                  .with(asset_manager_id, { "replacement_id" => replacement_asset_manager_id })

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

  def stub_create_asset(asset_manger_id)
    url_id = "http://asset-manager/assets/#{asset_manger_id}"
    Services.asset_manager.stubs(:create_asset)
            .returns("id" => url_id, "name" => "filename.pdf")
  end
end
