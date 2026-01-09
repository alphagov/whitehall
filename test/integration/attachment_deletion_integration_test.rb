require "test_helper"
require "capybara/rails"

class AttachmentDeletionIntegrationTest < ActionDispatch::IntegrationTest
  extend Minitest::Spec::DSL
  include Capybara::DSL
  include Rails.application.routes.url_helpers
  include TaxonomyHelper
  include Admin::EditionRoutesHelper

  describe "attachment deletion" do
    context "given a draft document with multiple file attachments" do
      let(:managing_editor) { create(:managing_editor) }
      let(:first_attachment) { build(:csv_attachment, attachable: edition, title: "first attachment") }
      let(:first_asset_id) { first_attachment.attachment_data.assets.first.asset_manager_id }
      let(:second_attachment) { build(:file_attachment, attachable: edition) }
      let(:second_asset_id) { second_attachment.attachment_data.assets.first.asset_manager_id }
      let(:edition) { create(:detailed_guide, :with_alternative_format_provider) }
      let(:topic_taxon) { build(:taxon_hash) }

      before do
        login_as(managing_editor)

        setup_publishing_api_for(edition)
        stub_publishing_api_has_linkables([], document_type: "topic")
        stub_publishing_api_expanded_links_with_taxons(edition.content_id, [])
        stub_publishing_api_links_with_taxons(edition.content_id, [topic_taxon["content_id"]])

        stub_asset(first_asset_id, { "draft" => true, "parent_document_url" => edition.public_url(draft: true) })
        stub_asset(second_asset_id, { "draft" => true, "parent_document_url" => edition.public_url(draft: true) })

        edition.attachments << [first_attachment, second_attachment]
        edition.save!
      end

      context "when one attachment is deleted" do
        it "deletes the corresponding asset in Asset Manager when the edition is published" do
          Services.asset_manager.expects(:delete_asset).never

          visit admin_edition_path(edition)
          click_link "Modify attachments"
          within page.find("li", text: first_attachment.title) do
            click_link "Delete attachment"
          end
          click_button "Delete attachment"
          assert_text "Attachment deleted"

          Services.asset_manager.expects(:delete_asset).once.with(first_asset_id)
          Services.asset_manager.expects(:update_asset).once.with(first_asset_id, has_entries({ "draft" => false, "parent_document_url" => edition.public_url(draft: false) }))
          Services.asset_manager.expects(:update_asset).once.with(second_asset_id, has_entries({ "draft" => false, "parent_document_url" => edition.public_url(draft: false) }))

          visit admin_edition_path(edition)
          click_link "Force publish"
          assert_text "Reason for force publishing"
          fill_in "Reason for force publishing", with: "testing"
          click_button "Force publish"
          assert_text "The document #{edition.title} has been published"

          PublishAttachmentAssetJob.drain
        end
      end

      context "when draft document is discarded" do
        it "deletes all corresponding assets in Asset Manager" do
          Services.asset_manager.expects(:delete_asset).once.with(first_asset_id)
          Services.asset_manager.expects(:delete_asset).once.with(second_asset_id)

          visit admin_edition_path(edition)
          click_link "Delete draft"
          click_button "Delete"

          DeleteAttachmentAssetJob.drain
        end
      end
    end

    context "given an unpublished document, with a new draft" do
      let(:managing_editor) { create(:managing_editor) }
      let(:earliest_attachable) { create(:detailed_guide, :unpublished, :with_file_attachment) }
      let(:latest_attachable) { earliest_attachable.reload.create_draft(managing_editor) }
      let(:attachment) { latest_attachable.attachments.first }
      let(:original_asset_manager_id) { attachment.attachment_data.assets.first.asset_manager_id }
      let(:topic_taxon) { build(:taxon_hash) }

      before do
        login_as(managing_editor)

        setup_publishing_api_for(latest_attachable)
        stub_publishing_api_has_linkables([], document_type: "topic")
        stub_publishing_api_expanded_links_with_taxons(latest_attachable.content_id, [])
        stub_publishing_api_links_with_taxons(latest_attachable.content_id, [topic_taxon["content_id"]])

        stub_asset(original_asset_manager_id, { "draft" => false, "parent_document_url" => latest_attachable.public_url(draft: false) })

        latest_attachable.update!(minor_change: true)
      end

      it "does not delete the asset when the draft is discarded, if the attachment was present on the previous edition" do
        Services.asset_manager.expects(:delete_asset).never

        visit admin_detailed_guide_path(latest_attachable)
        click_link "Delete draft"
        assert_text "Are you sure you want to delete this draft?"
        click_button "Delete"
        assert_text "The draft of '#{latest_attachable.title}' has been deleted"

        DeleteAttachmentAssetJob.drain
      end
    end

    context "given a published document with a draft" do
      let(:managing_editor) { create(:managing_editor) }
      let(:earliest_attachable) { create(:published_detailed_guide, :with_file_attachment) }
      let(:latest_attachable) { earliest_attachable.reload.create_draft(managing_editor) }
      let(:attachment) { latest_attachable.attachments.first }
      let(:original_asset_manager_id) { attachment.attachment_data.assets.first.asset_manager_id }
      let(:topic_taxon) { build(:taxon_hash) }

      before do
        login_as(managing_editor)

        setup_publishing_api_for(latest_attachable)
        stub_publishing_api_has_linkables([], document_type: "topic")
        stub_publishing_api_expanded_links_with_taxons(latest_attachable.content_id, [])
        stub_publishing_api_links_with_taxons(latest_attachable.content_id, [topic_taxon["content_id"]])

        stub_asset(original_asset_manager_id, { "draft" => false, "parent_document_url" => latest_attachable.public_url(draft: false) })

        latest_attachable.update!(minor_change: true)
      end

      it "deletes the corresponding asset in Asset Manager only when the new draft gets published" do
        visit admin_edition_path(latest_attachable)
        click_link "Modify attachments"
        within page.find("li", text: attachment.title) do
          click_link "Delete attachment"
        end
        click_button "Delete attachment"
        assert_text "Attachment deleted"

        Services.asset_manager.expects(:delete_asset).once.with(original_asset_manager_id)
        Services.asset_manager.expects(:update_asset).never

        visit admin_edition_path(latest_attachable)
        click_link "Force publish"
        assert_text "Reason for force publishing"
        fill_in "Reason for force publishing", with: "testing"
        click_button "Force publish"
        assert_text "The document #{latest_attachable.title} has been published"

        PublishAttachmentAssetJob.drain
      end

      context "when the attachment has been replaced" do
        let(:replacement_asset_manager_id) { "replacement_asset_manager_id" }

        before do
          stub_asset(replacement_asset_manager_id, { "draft" => true, "parent_document_url" => latest_attachable.public_url(draft: true) })

          replacement_data = create(:attachment_data, attachable: latest_attachable, file: upload_fixture("two-pages.pdf"))
          attachment.attachment_data.replaced_by = replacement_data
          attachment.attachment_data.save!

          asset = replacement_data.assets.first
          asset.asset_manager_id = replacement_asset_manager_id
          asset.save!

          attachment.attachment_data = replacement_data
          attachment.save!
        end

        it "deletes the corresponding asset in Asset Manager and updates the asset to live, only when the new draft gets published" do
          visit admin_edition_path(latest_attachable)
          click_link "Modify attachments"
          within page.find("li", text: attachment.title) do
            click_link "Delete attachment"
          end
          click_button "Delete attachment"
          assert_text "Attachment deleted"

          Services.asset_manager.expects(:delete_asset).once.with(replacement_asset_manager_id)
          Services.asset_manager.expects(:update_asset).once.with(replacement_asset_manager_id, has_entries({ "draft" => false, "parent_document_url" => latest_attachable.public_url(draft: false) }))

          visit admin_edition_path(latest_attachable)
          click_link "Force publish"
          assert_text "Reason for force publishing"
          fill_in "Reason for force publishing", with: "testing"
          click_button "Force publish"
          assert_text "The document #{latest_attachable.title} has been published"

          PublishAttachmentAssetJob.drain
        end
      end
    end

    context "given an outcome on a draft consultation" do
      let(:managing_editor) { create(:managing_editor) }
      let(:topic_taxon) { build(:taxon_hash) }
      let(:edition) { create(:draft_consultation) }
      let(:attachable) { edition.create_outcome!(FactoryBot.attributes_for(:consultation_outcome)) }
      let(:attachment) { build(:csv_attachment, attachable:) }
      let(:asset_id) { attachment.attachment_data.assets.first.asset_manager_id }

      before do
        login_as(managing_editor)

        setup_publishing_api_for(edition)
        stub_publishing_api_has_linkables([], document_type: "topic")
        stub_publishing_api_expanded_links_with_taxons(edition.content_id, [])
        stub_publishing_api_links_with_taxons(edition.content_id, [topic_taxon["content_id"]])

        stub_asset(asset_id, { "draft" => true, "parent_document_url" => nil })

        attachable.attachments << [attachment]
        attachable.save!
      end

      it "deletes the corresponding asset in Asset Manager when the edition is published and updates its draft setting to false" do
        Services.asset_manager.expects(:delete_asset).never

        visit admin_consultation_path(edition)
        click_link "Edit draft"
        click_link "Final outcome"
        within page.find("li", text: attachment.title) do
          click_link "Delete attachment"
        end
        click_button "Delete attachment"
        assert_text "Attachment deleted"

        Services.asset_manager.expects(:delete_asset).once.with(asset_id)
        Services.asset_manager.expects(:update_asset).once.with(asset_id, has_entries({ "draft" => false }))

        visit admin_consultation_path(edition)
        click_link "Force publish"
        assert_text "Reason for force publishing"
        fill_in "Reason for force publishing", with: "testing"
        click_button "Force publish"
        assert_text "The document #{edition.title} has been published"

        PublishAttachmentAssetJob.drain
      end

      context "when draft consultation is discarded" do
        it "deletes all outcome attachment assets in Asset Manager" do
          Services.asset_manager.expects(:delete_asset).once.with(asset_id)

          visit admin_consultation_path(edition)
          click_link "Delete draft"
          click_button "Delete"

          DeleteAttachmentAssetJob.drain
        end
      end
    end

    context "given a policy group" do
      let(:gds_editor) { create(:gds_editor) }
      let(:attachable) { create(:policy_group) }
      let(:first_attachment) { build(:file_attachment, attachable:) }
      let(:second_attachment) { build(:csv_attachment, attachable:) }
      let(:first_asset_manager_id) { first_attachment.attachment_data.assets.first.asset_manager_id }
      let(:second_asset_manager_id) { second_attachment.attachment_data.assets.first.asset_manager_id }

      before do
        login_as(gds_editor)
        stub_asset(first_asset_manager_id, { "draft" => false, "parent_document_url" => nil })
        stub_asset(second_asset_manager_id, { "draft" => false, "parent_document_url" => nil })

        attachable.attachments << [first_attachment, second_attachment]
        attachable.save!
      end

      it "deletes the corresponding asset in Asset Manager for a deleted attachment, when the policy group is saved" do
        Services.asset_manager.expects(:delete_asset).once.with(first_asset_manager_id)
        Services.asset_manager.expects(:update_asset).with(first_asset_manager_id).never

        visit admin_policy_group_attachments_path(attachable)
        within page.find("li", text: first_attachment.title) do
          click_link "Delete attachment"
        end
        click_button "Delete attachment"
        assert_text "Attachment deleted"
        click_link "Group"
        click_button "Save"

        DeleteAttachmentAssetJob.drain
      end

      it "deleted the corresponding assets of all attachments, when the policy group is deleted" do
        Services.asset_manager.expects(:delete_asset).once.with(first_asset_manager_id)
        Services.asset_manager.expects(:delete_asset).once.with(second_asset_manager_id)

        visit admin_policy_groups_path
        within page.find("tr", text: attachable.name) do
          click_link "Delete"
        end
        click_button "Delete"
        assert_text "\"#{attachable.name}\" deleted."

        assert_equal first_attachment.reload.deleted, true
        assert_equal second_attachment.reload.deleted, true

        DeleteAttachmentAssetJob.drain
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
