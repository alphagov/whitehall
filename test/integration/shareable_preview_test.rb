require "test_helper"
require "capybara/rails"

class ShareablePreviewIntegrationTest < ActionDispatch::IntegrationTest
  extend Minitest::Spec::DSL
  include Capybara::DSL
  include TaxonomyHelper

  describe "shareable preview feature" do
    context "for draft documents" do
      let(:edition) { create(:draft_case_study) }

      before do
        create_setup(edition)
        visit admin_case_study_path(edition)
      end

      test "it shows shareable preview feature" do
        get admin_case_study_path(edition)
        assert_selector "section", text: "Share document preview"
      end
    end

    context "for published documents" do
      let(:edition) { create(:published_case_study) }

      before do
        create_setup(edition)
        visit admin_case_study_path(edition)
      end

      test "it does not show shareable preview feature" do
        get admin_case_study_path(edition)
        assert_no_selector "section", text: "Share document preview"
      end
    end

    context "for draft documents when the user does not have a permission" do
      let(:edition) { create(:draft_case_study) }

      before do
        create_setup(edition)
        @user.permissions = []
        visit admin_case_study_path(edition)
      end

      test "it shows shareable preview feature" do
        get admin_case_study_path(edition)
        assert_no_selector "section", text: "Share document preview"
      end
    end

    #  test below will be removed after enabling shareable preview for those doccument types
    context "for excluded type of documents - document collection" do
      let(:edition) { create(:draft_document_collection) }

      before do
        create_setup(edition)
        visit admin_document_collection_path(edition)
      end

      test "it does not show shareable preview feature" do
        get admin_document_collection_path(edition)
        assert_no_selector "section", text: "Share document preview"
      end
    end

    def create_setup(edition)
      @user = create(:gds_editor)
      @user.permissions << "can share previews"
      login_as @user
      topic_taxon = build(:taxon_hash)
      stub_publishing_api_expanded_links_with_taxons(edition.content_id, [])
      stub_publishing_api_links_with_taxons(edition.content_id, [topic_taxon["content_id"]])
    end
  end
end
