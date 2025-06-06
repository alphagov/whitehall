require "test_helper"
require "capybara/rails"

class AttachmentReplacementIntegrationTest < ActionDispatch::IntegrationTest
  extend Minitest::Spec::DSL
  include Capybara::DSL
  include Rails.application.routes.url_helpers
  include TaxonomyHelper

  describe "attachment replacement" do
    let(:managing_editor) { create(:managing_editor) }
    let(:filename) { "sample.csv" }
    let(:replacement_filename) { "sample.rtf" }
    let(:double_replacement_filename) { "sample.docx" }
    let(:asset_manager_id) { "asset_manager_id" }
    let(:replacement_asset_manager_id) { "replacement-asset-id" }
    let(:double_replacement_asset_manager_id) { "double-replacement-asset-id" }
    let(:variant) { Asset.variants[:original] }
    let(:attachment) { build(:csv_attachment, title: "attachment-title", attachable: edition) }

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
          Sidekiq::Job.clear_all

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

          AssetManagerCreateAssetWorker.drain
          PublishingApiDraftUpdateWorker.drain
          AssetManagerAttachmentMetadataWorker.drain
        end
      end
    end

    context "given a published document with file attachment" do
      let(:edition) { create(:published_news_article) }

      context "when new draft is created and attachment is replaced" do
        before do
          Sidekiq::Job.clear_all

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
          AssetManagerCreateAssetWorker.drain

          Services.asset_manager.expects(:update_asset)
                  .at_least_once
                  .with(asset_manager_id, { "replacement_id" => replacement_asset_manager_id })

          AssetManagerAttachmentMetadataWorker.drain
        end
      end

      context "when new draft is created and attachment is replaced twice" do
        before do
          [
            { id: replacement_asset_manager_id, filename: replacement_filename },
            { id: double_replacement_asset_manager_id, filename: double_replacement_filename },
          ].each do |item|
            Services.asset_manager.expects(:create_asset).with { |args|
              args[:file].path =~ /#{item[:filename]}/
            }.returns("id" => "http://asset-manager/assets/#{item[:id]}", "name" => item[:filename])
          end
          stub_asset(double_replacement_asset_manager_id)

          Sidekiq::Job.clear_all
        end

        it "without pre-saving the edition - updates draft & replacement for asset in Asset Manager" do
          visit admin_news_article_path(edition)
          click_button "Create new edition"

          AssetManagerAttachmentMetadataWorker.drain
          AssetManagerCreateAssetWorker.drain
          PublishingApiDraftUpdateWorker.drain
          AssetManagerAttachmentMetadataWorker.drain

          Services.asset_manager.expects(:update_asset)
                  .with(asset_manager_id, { "replacement_id" => replacement_asset_manager_id })
                  .once
          Services.asset_manager.expects(:update_asset)
                  .with(replacement_asset_manager_id, has_entry({ "draft" => true }))
                  .once

          click_link "Attachments 1"
          within page.find("li", text: filename) do
            click_link "Edit attachment"
          end
          attach_file "Replace file", path_to_attachment(replacement_filename)
          click_button "Save"
          assert_text "Attachment 'attachment-title' updated"

          AssetManagerAttachmentMetadataWorker.drain
          AssetManagerCreateAssetWorker.drain
          PublishingApiDraftUpdateWorker.drain
          AssetManagerAttachmentMetadataWorker.drain

          Services.asset_manager.expects(:update_asset)
                  .with(replacement_asset_manager_id, { "replacement_id" => double_replacement_asset_manager_id })
                  .once
          Services.asset_manager.expects(:update_asset)
                  .with(double_replacement_asset_manager_id, has_entry({ "draft" => true }))
                  .once

          within page.find("li", text: replacement_filename) do
            click_link "Edit attachment"
          end
          attach_file "Replace file", path_to_attachment(double_replacement_filename)
          click_button "Save"
          assert_text "Attachment 'attachment-title' updated"

          AssetManagerAttachmentMetadataWorker.drain
          AssetManagerCreateAssetWorker.drain
          PublishingApiDraftUpdateWorker.drain
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
