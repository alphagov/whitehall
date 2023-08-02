require "test_helper"
require "capybara/rails"

class DocumentCollectionEmailOverrideTest < ActionDispatch::IntegrationTest
  extend Minitest::Spec::DSL
  include Capybara::DSL
  include Rails.application.routes.url_helpers
  include TaxonomyHelper

  describe "adding an email override" do
    let(:document_collection) { create(:document_collection) }

    context "as a user with the email override editor permission" do
      let(:user_with_permission_to_override) { create(:writer, permissions: [User::Permissions::EMAIL_OVERRIDE_EDITOR]) }

      before do
        login_as(user_with_permission_to_override)
      end

      it "updates the taxonomy topic email override" do
        visit edit_admin_document_collection_path(document_collection)
        click_link "Email notifications"

        page.choose("Emails about the topic")
        select "Topic One", from: "selected_taxon_content_id"
        page.check("Select this box to confirm you're happy with what you've selected.")
        click_button("Save")
        document_collection.reload
        assert_equal document_collection.taxonomy_topic_email_override, "9b889c60-2191-11ee-be56-0242ac120002"
      end

      it "does not update taxonomy topic email if confirmation button is unchecked" do
        visit edit_admin_document_collection_path(document_collection)
        click_link "Email notifications"

        page.choose("Emails about the topic")
        select "Topic One", from: "selected_taxon_content_id"
        click_button("Save")
        document_collection.reload
        assert_nil document_collection.taxonomy_topic_email_override
      end

      it "does not update taxonomy topic email if topic is not selected" do
        visit edit_admin_document_collection_path(document_collection)
        click_link "Email notifications"

        page.choose("Emails about the topic")
        click_button("Save")
        document_collection.reload
        assert_nil document_collection.taxonomy_topic_email_override
      end
    end

    context "as a user without the email override editor permission" do
      let(:user_without_permission_to_override) { create(:writer) }

      before do
        login_as(user_without_permission_to_override)
      end

      it "the tab to edit the taxonomy topic email override is not visible" do
        visit edit_admin_document_collection_path(document_collection)
        assert page.has_no_link?("Email notifications")
      end

      it "visiting the edit email url directly redirects the user with a permission error" do
        visit admin_document_collection_edit_email_subscription_path(document_collection)

        assert_equal page.current_path, edit_admin_document_collection_path(document_collection)
      end
    end
  end
end
