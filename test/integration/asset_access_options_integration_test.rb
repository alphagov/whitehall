require "test_helper"
require "capybara/rails"

class AssetAccessOptionsIntegrationTest < ActionDispatch::IntegrationTest
  extend Minitest::Spec::DSL
  include Capybara::DSL
  include Rails.application.routes.url_helpers
  include TaxonomyHelper
  include Admin::EditionRoutesHelper

  describe "attachment access options (auth_bypass_id and access_limiting)" do
    let(:organisation) { create(:organisation) }
    let(:managing_editor) { create(:managing_editor, organisation:, uid: "user-uid") }
    let(:asset_manager_id) { "asset_manager_id" }
    let(:asset_manager_response) do
      { "id" => "http://asset-manager/assets/#{asset_manager_id}", "name" => "asset-title" }
    end

    before do
      login_as managing_editor
      setup_publishing_api_for(edition)
      stub_publishing_api_has_linkables([], document_type: "topic")
      stub_asset(asset_manager_id, draft: true)
    end

    context "forwarding the preview token to Asset Manager" do
      before do
        add_file_attachment_with_asset("logo.png", to: edition)
        edition.save!
      end

      context "when the draft has a preview token" do
        let(:edition) { create(:detailed_guide, :with_auth_bypass_id) }

        it "sends the attachment with the document's auth_bypass_id" do
          Services.asset_manager.expects(:create_asset).at_least_once.with(
            has_entries(auth_bypass_ids: [edition.auth_bypass_id]),
          ).returns(asset_manager_response)

          AssetManagerCreateAssetJob.drain
        end
      end

      context "when the draft has no preview token" do
        let(:edition) { create(:detailed_guide) }

        it "sends the attachment with an empty auth_bypass_ids" do
          Services.asset_manager.expects(:create_asset).at_least_once.with(
            has_entries(auth_bypass_ids: []),
          ).returns(asset_manager_response)

          AssetManagerCreateAssetJob.drain
        end
      end
    end

    context "applying access limiting to a draft's attachments" do
      context "when a draft is marked as access limited" do
        let(:edition) { create(:detailed_guide, organisations: [organisation]) }

        before do
          add_file_attachment_with_asset("sample.docx", to: edition)
          edition.save!
          visit edit_admin_edition_path(edition)
          check "Limit access"
          click_button "Save"
          assert_text "Your document has been saved"
        end

        it "marks the attachment as access limited in Asset Manager" do
          Services.asset_manager
                  .expects(:update_asset)
                  .at_least_once.with(asset_manager_id, has_entry("access_limited_organisation_ids", [organisation.content_id]))

          AssetManagerAttachmentMetadataJob.drain
        end
      end

      context "when a draft is unmarked as access limited" do
        let(:edition) { create(:detailed_guide, organisations: [organisation], access_limiting: "organisations") }

        before do
          add_file_attachment_with_asset("sample.docx", to: edition)
          edition.save!
          visit edit_admin_edition_path(edition)
          uncheck "Limit access"
          click_button "Save"
          assert_text "Your document has been saved"
        end

        it "unmarks the attachment as access limited in Asset Manager" do
          Services.asset_manager
                  .expects(:update_asset)
                  .at_least_once.with(asset_manager_id, has_entry("access_limited_organisation_ids", []))

          AssetManagerAttachmentMetadataJob.drain
        end
      end

      context "when an attachment is added to an access-limited draft" do
        let(:edition) { create(:detailed_guide, organisations: [organisation], access_limiting: "organisations") }

        before do
          visit admin_edition_path(edition)
          click_link "Add attachments"
          page.attach_file path_to_attachment("logo.png")
          click_button "Upload"
          fill_in "Title", with: "logo.png"
          click_button "Save"
          assert_text "Attachment 'logo.png' uploaded"
        end

        it "marks the attachment as access limited in Asset Manager" do
          Services.asset_manager.expects(:create_asset).with(
            has_entries(access_limited_organisation_ids: [organisation.content_id]),
          ).returns(asset_manager_response)

          AssetManagerCreateAssetJob.drain
        end
      end

      context "when multiple files are uploaded to an access-limited draft" do
        let(:edition) { create(:detailed_guide, organisations: [organisation], access_limiting: "organisations") }

        before do
          visit admin_edition_path(edition)
          click_link "Add attachments"
          page.attach_file [path_to_attachment("logo.png"), path_to_attachment("greenpaper.pdf")]
          click_button "Upload"
          fill_in "upload[attachments][0][title]", with: "file-title"
          fill_in "upload[attachments][1][title]", with: "file-title"
          click_button "Save"
          assert find("li", text: "greenpaper.pdf")
          assert find("li", text: "logo.png")
        end

        it "marks each attachment as access limited in Asset Manager" do
          Services.asset_manager
                  .expects(:create_asset)
                  .at_least(2)
                  .with(
                    has_entries(access_limited_organisation_ids: [organisation.content_id]),
                  ).returns(asset_manager_response)

          AssetManagerCreateAssetJob.drain
        end
      end

      context "when an attachment is replaced on an access-limited draft" do
        let(:edition) { create(:detailed_guide, organisations: [organisation], access_limiting: "organisations") }

        before do
          add_file_attachment_with_asset("sample.docx", to: edition)
          edition.save!
          visit admin_edition_path(edition)
          click_link "Edit attachments"
          click_link "Edit"
          attach_file "Replace file", path_to_attachment("big-cheese.960x640.jpg")
          click_button "Save"
          assert_text "Attachment 'sample.docx' updated"
        end

        it "marks the replacement attachment as access limited in Asset Manager" do
          Services.asset_manager.stubs(:create_asset).returns(asset_manager_response)
          Services.asset_manager.expects(:create_asset).with { |params| params[:access_limited_organisation_ids] == [organisation.content_id] }.returns(asset_manager_response)

          AssetManagerCreateAssetJob.drain
        end
      end

      context "when an attachment is added to an access-limited consultation outcome" do
        # the edition has to have same organisation as logged in user, otherwise it's not visible when access_limited = true
        let(:edition) { create(:consultation, organisations: [organisation], access_limiting: "organisations") }
        let(:outcome_attributes) { FactoryBot.attributes_for(:consultation_outcome) }
        let!(:outcome) { edition.create_outcome!(outcome_attributes) }

        before do
          visit admin_consultation_path(edition)
          click_link "Edit draft"
          click_link "Final outcome"
          page.attach_file path_to_attachment("logo.png")
          click_button "Upload"
          fill_in "Title", with: "asset-title"
          click_button "Save"
          assert_text "Attachment 'asset-title' uploaded"
        end

        it "marks the attachment as access limited in Asset Manager" do
          Services.asset_manager.expects(:create_asset).with(
            has_entries(access_limited_organisation_ids: [organisation.content_id]),
          ).returns(asset_manager_response)
          AssetManagerCreateAssetJob.drain
        end
      end
    end

  private

    def setup_publishing_api_for(edition)
      stub_publishing_api_has_links(
        {
          content_id: edition.document.content_id,
          links: {},
        },
      )

      stub_publishing_api_expanded_links_with_taxons(edition.content_id, [])
    end

    def add_file_attachment_with_asset(filename, to:)
      to.alternative_format_provider = create(:organisation, :with_alternative_format_contact_email) if to.respond_to?(:alternative_format_provider)
      to.attachments << FactoryBot.build(
        :file_attachment,
        title: filename,
        attachable: to,
      )
    end

    def path_to_attachment(filename)
      fixture_path.join(filename)
    end

    def stub_asset(asset_manager_id, attributes = {})
      url_id = "http://asset-manager/assets/#{asset_manager_id}"
      Services.asset_manager.stubs(:asset)
              .with(asset_manager_id)
              .returns(attributes.merge(id: url_id).stringify_keys)
    end
  end
end
