require "test_helper"
require "capybara/rails"

class ShareablePreviewIntegrationTest < ActionDispatch::IntegrationTest
  extend Minitest::Spec::DSL
  include Capybara::DSL
  include TaxonomyHelper
  include Admin::EditionRoutesHelper

  describe "shareable preview feature" do
    before do
      login_as create(:gds_editor)
      topic_taxon = build(:taxon_hash)
      stub_publishing_api_expanded_links_with_taxons(edition.content_id, [])
      stub_publishing_api_links_with_taxons(edition.content_id, [topic_taxon["content_id"]])
      visit admin_edition_path(edition)
    end

    context "for a draft with a preview link" do
      let(:edition) { create(:draft_publication, :with_auth_bypass_id) }

      test "it shows the preview link with copy, regenerate and delete controls" do
        open_share_preview_section

        assert page.has_button?("Copy link")
        assert page.has_button?("Generate new link")
        assert page.has_button?("Delete link")
      end

      test "it regenerates the preview link, replacing the previous one" do
        open_share_preview_section
        previous_token = preview_token_in_page

        click_button "Generate new link"
        assert page.has_content?("New document preview link generated")

        open_share_preview_section
        assert_not_equal previous_token, preview_token_in_page
      end

      test "it deletes the preview link and can generate a new one from the empty state" do
        open_share_preview_section

        click_button "Delete link"
        assert page.has_content?("Document preview link deleted")

        open_share_preview_section
        assert page.has_button?("Generate link")
        assert page.has_no_button?("Copy link")
        assert page.has_no_button?("Delete link")

        click_button "Generate link"
        assert page.has_content?("New document preview link generated")

        open_share_preview_section
        assert page.has_button?("Copy link")
        assert page.has_button?("Delete link")
      end
    end

    context "for a published document" do
      let(:edition) { create(:published_publication) }

      test "it does not show the shareable preview feature" do
        assert_not page.has_content?("Share preview link with someone else")
      end
    end

    def open_share_preview_section
      find(".govuk-details__summary", text: "Share preview link with someone else").click
    end

    def preview_token_in_page
      preview_url = all("input").first.value
      Rack::Utils.parse_query(URI(preview_url).query)["token"]
    end
  end
end
