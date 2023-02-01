require "test_helper"
require "capybara/rails"

class ShareablePreviewGenerateNewLinkIntegrationTest < ActionDispatch::IntegrationTest
  extend Minitest::Spec::DSL
  include Capybara::DSL
  include TaxonomyHelper

  describe "shareable preview generate new link feature" do
    context "for draft documents" do
      let(:edition) { create(:draft_case_study) }

      before do
        create_setup(edition)
        visit admin_case_study_path(edition)
      end

      test "it shows the generate new link feature" do
        get admin_case_study_path(edition)
        assert_selector "section", text: "Generate new link"
      end

      test "it revokes the previous links and generates a new one" do
        get admin_case_study_path(edition)

        find(".govuk-details__summary", text: "Share document preview").click

        current_preview_url = all("input").first.value
        current_query_string = Rack::Utils.parse_query URI(current_preview_url).query
        current_token = current_query_string["token"]

        click_button "Generate new link"

        find(".govuk-details__summary", text: "Share document preview").click

        new_preview_url = all("input").first.value
        new_query_string = Rack::Utils.parse_query URI(new_preview_url).query
        new_token = new_query_string["token"]

        assert_selector ".gem-c-success-alert__message", text: "New document preview link generated"
        assert_not_equal current_token, new_token
      end
    end

    context "for published documents" do
      let(:edition) { create(:published_case_study) }

      before do
        create_setup(edition)
        visit admin_case_study_path(edition)
      end

      test "it does not show the generate new link feature" do
        get admin_case_study_path(edition)
        assert_no_selector "section", text: "Generate new link"
      end
    end

    def create_setup(edition)
      @user = create(:gds_editor)
      login_as @user
      topic_taxon = build(:taxon_hash)
      stub_publishing_api_expanded_links_with_taxons(edition.content_id, [])
      stub_publishing_api_links_with_taxons(edition.content_id, [topic_taxon["content_id"]])
    end
  end
end
