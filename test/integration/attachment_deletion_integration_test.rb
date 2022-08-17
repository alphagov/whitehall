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

      let(:first_filename) { "sample.docx" }
      let(:first_file) { File.open(path_to_attachment(first_filename)) }
      let(:first_attachment) { build(:file_attachment, attachable: edition, file: first_file) }
      let(:first_asset_id) { "first-asset-id" }

      let(:second_filename) { "sample.rtf" }
      let(:second_file) { File.open(path_to_attachment(second_filename)) }
      let(:second_attachment) { build(:file_attachment, attachable: edition, file: second_file) }
      let(:second_asset_id) { "second-asset-id" }

      let(:edition) { create(:news_article) }

      before do
        login_as(managing_editor)
        stub_publishing_api_has_linkables([], document_type: "topic")
        edition.attachments << first_attachment
        edition.attachments << second_attachment
        setup_publishing_api_for(edition)
        stub_publishing_api_expanded_links_with_taxons(edition.content_id, [])
        stub_whitehall_asset(first_filename, id: first_asset_id)
        stub_whitehall_asset(second_filename, id: second_asset_id)
        first_attachment.attachment_data.uploaded_to_asset_manager!
        second_attachment.attachment_data.uploaded_to_asset_manager!
        edition.save!

        # clear the queue of jobs resulting from test setup
        AssetManagerAttachmentMetadataWorker.drain
      end

      context "when one attachment is deleted" do
        before do
          visit admin_news_article_path(edition)
          click_link "Modify attachments"
          within "#attachment_#{first_attachment.id}" do
            click_link "Delete"
          end
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
          click_link "Discard draft"
          click_button "Discard"
        end

        it "deletes all corresponding assets in Asset Manager" do
          Services.asset_manager.expects(:delete_asset).once.with(first_asset_id)
          Services.asset_manager.expects(:delete_asset).once.with(second_asset_id)
          assert_equal AssetManagerAttachmentMetadataWorker.jobs.count, 2
          AssetManagerAttachmentMetadataWorker.drain
        end
      end
    end

  private

    def ends_with(expected)
      ->(actual) { actual.end_with?(expected) }
    end

    def setup_publishing_api_for(edition)
      stub_publishing_api_has_links({ content_id: edition.document.content_id, links: {} })
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
  end
end
