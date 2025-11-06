require "test_helper"
require "capybara/rails"

class AssetAccessOptionsIntegrationTest < ActionDispatch::IntegrationTest
  extend Minitest::Spec::DSL
  include Capybara::DSL
  include Rails.application.routes.url_helpers
  include TaxonomyHelper

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

    context "given a draft document with file attachment" do
      let(:edition) { create(:news_article, organisations: [organisation]) }

      before do
        add_file_attachment_with_asset("sample.docx", to: edition)
        edition.save!
      end

      context "when document is marked as access limited in Whitehall" do
        before do
          visit edit_admin_news_article_path(edition)
          check "Limit access"
          click_button "Save"
          assert_text "Your document has been saved"
        end

        it "marks attachment as access limited in Asset Manager" do
          Services.asset_manager
                  .expects(:update_asset)
                  .at_least_once.with(asset_manager_id, has_entry("access_limited_organisation_ids", [organisation.content_id]))

          AssetManagerAttachmentMetadataWorker.drain
        end
      end
    end

    context "given a draft document with an image attachment" do
      let(:edition) { create(:draft_case_study) }

      before do
        visit admin_case_study_path(edition)
        click_link "Edit draft"
        click_link "Images"
        attach_file "images[][image_data][file]", path_to_attachment("minister-of-funk.960x640.jpg")
        click_button "Upload"
      end

      # Note that there is no access limiting applied to non attachments. This is existing behaviour that probably needs changing.
      it "sends an image to asset manager with the document's auth_bypass_id" do
        Services.asset_manager.expects(:create_asset).at_least_once.with(
          has_entry(auth_bypass_ids: [edition.auth_bypass_id]),
        ).returns(asset_manager_response)

        AssetManagerCreateAssetWorker.drain
      end
    end

    context "given an access-limited draft document" do
      let(:edition) { create(:news_article, organisations: [organisation], access_limited: true) }

      context "when an attachment is added to the draft document" do
        before do
          visit admin_news_article_path(edition)
          click_link "Add attachments"
          page.attach_file path_to_attachment("logo.png")
          click_button "Upload"
          fill_in "Title", with: "logo.png"
          click_button "Save"
          assert_text "Attachment 'logo.png' uploaded"
        end

        it "marks attachment as access limited and sends it with an auth_bypass_id in Asset Manager" do
          Services.asset_manager.expects(:create_asset).with(
            has_entries(
              access_limited_organisation_ids: [organisation.content_id],
              auth_bypass_ids: [edition.auth_bypass_id],
            ),
          ).returns(asset_manager_response)

          AssetManagerCreateAssetWorker.drain
        end
      end

      context "when an html attachment is added to the draft document" do
        let(:edition) { create(:publication, :policy_paper) }

        before do
          visit admin_publication_path(edition)
          click_link "Modify attachments"
          click_link "Add new HTML attachment"
          fill_in "Title", with: "html-attachment"
          fill_in "Body", with: "some html content"
        end

        it "sends an html attachment to publishing api with its edition's auth_bypass_id" do
          Services.publishing_api.expects(:put_content)
                  .with(anything, has_entries(title: edition.title))
          Services.publishing_api.expects(:put_content)
                  .with(anything, has_entries(title: edition.attachments.first.title))

          Services.publishing_api.expects(:put_content).at_least_once
                  .with(anything, has_entries(
                                    title: "html-attachment",
                                    auth_bypass_ids: [edition.auth_bypass_id],
                                  ))

          click_button "Save"
        end
      end

      context "when bulk uploaded to draft document" do
        before do
          visit admin_news_article_path(edition)
          click_link "Add attachments"
          page.attach_file [path_to_attachment("logo.png"), path_to_attachment("greenpaper.pdf")]
          click_button "Upload"
          fill_in "bulk_upload[attachments][0][title]", with: "file-title"
          fill_in "bulk_upload[attachments][1][title]", with: "file-title"
          click_button "Save"
          assert find("li", text: "greenpaper.pdf")
          assert find("li", text: "logo.png")
        end

        it "marks attachment as access limited in Asset Manager" do
          Services.asset_manager
                  .expects(:create_asset)
                  .at_least(2)
                  .with(
                    has_entries(
                      access_limited_organisation_ids: [organisation.content_id],
                      auth_bypass_ids: [edition.auth_bypass_id],
                    ),
                  ).returns(asset_manager_response)

          AssetManagerCreateAssetWorker.drain
        end
      end
    end

    context "given an access-limited draft document and a file attachment" do
      let(:edition) { create(:news_article, organisations: [organisation], access_limited: true) }

      before do
        add_file_attachment_with_asset("sample.docx", to: edition)
        edition.save!
      end

      context "when document is unmarked as access limited in Whitehall" do
        before do
          visit edit_admin_news_article_path(edition)
          uncheck "Limit access"
          click_button "Save"
          assert_text "Your document has been saved"
        end

        it "unmarks attachment as access limited in Asset Manager" do
          Services.asset_manager
                  .expects(:update_asset)
                  .at_least_once.with(asset_manager_id, has_entry("access_limited_organisation_ids", []))

          AssetManagerAttachmentMetadataWorker.drain
        end
      end

      context "when attachment is replaced" do
        before do
          visit admin_news_article_path(edition)
          click_link "Modify attachments"
          click_link "Edit"
          attach_file "Replace file", path_to_attachment("big-cheese.960x640.jpg")
          click_button "Save"
          assert_text "Attachment 'sample.docx' updated"
        end

        it "marks replacement attachment as access limited in Asset Manager" do
          Services.asset_manager.stubs(:create_asset).returns(asset_manager_response)
          Services.asset_manager.expects(:create_asset).with { |params|
            params[:access_limited_organisation_ids] == [organisation.content_id] &&
              params[:auth_bypass_ids] == [edition.auth_bypass_id]
          }.returns(asset_manager_response)

          AssetManagerCreateAssetWorker.drain
        end
      end
    end

    context "given a draft access-limited consultation" do
      # the edition has to have same organisation as logged in user, otherwise it's not visible when access_limited = true
      let(:edition) { create(:consultation, organisations: [organisation], access_limited: true) }
      let(:outcome_attributes) { FactoryBot.attributes_for(:consultation_outcome) }
      let!(:outcome) { edition.create_outcome!(outcome_attributes) }

      context "when an attachment is added to the consultation's outcome" do
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

        it "marks attachment as access limited in Asset Manager and sends with the consultation's auth_bypass_id" do
          Services.asset_manager.expects(:create_asset).with(
            has_entries(
              access_limited_organisation_ids: [organisation.content_id],
              auth_bypass_ids: [edition.auth_bypass_id],
            ),
          ).returns(asset_manager_response)
          AssetManagerCreateAssetWorker.drain
        end
      end

      it "sends a consultation form to asset manager with the consultation's auth_bypass_id" do
        visit admin_consultation_path(edition)
        click_link "Edit draft"
        name_of_form_uploader = "edition[consultation_participation_attributes][consultation_response_form_attributes][consultation_response_form_data_attributes][file]"
        fill_in "edition[consultation_participation_attributes][consultation_response_form_attributes][title]", with: "Consultation response form"
        attach_file name_of_form_uploader, path_to_attachment("simple.pdf")
        click_button "Save"

        # Note that there is no access limiting applied to non attachments. This is existing behaviour that probably needs changing.
        Services.asset_manager.expects(:create_asset).with { |args|
          args[:file].path =~ /simple\.pdf/
          args[:auth_bypass_ids] == [edition.auth_bypass_id]
        }.returns(asset_manager_response)

        AssetManagerCreateAssetWorker.drain
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
