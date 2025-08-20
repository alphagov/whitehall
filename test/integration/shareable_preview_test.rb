require "test_helper"
require "capybara/rails"

class ShareablePreviewIntegrationTest < ActionDispatch::IntegrationTest
  extend Minitest::Spec::DSL
  include TaxonomyHelper

  describe "shareable preview feature" do
    context "for draft documents" do
      let(:edition) { create(:draft_case_study) }

      before do
        create_setup(edition)
      end

      test "it shows shareable preview feature" do
        get admin_case_study_path(edition)
        assert_select ".govuk-details__summary-text", text: "Share document preview"
      end
    end

    context "for published documents" do
      let(:edition) { create(:published_case_study) }

      before do
        create_setup(edition)
      end

      test "it does not show shareable preview feature" do
        get admin_case_study_path(edition)
        refute_select ".govuk-details__summary-text", text: "Share document preview"
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
