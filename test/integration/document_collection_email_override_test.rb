require "test_helper"
require "capybara/rails"

class DocumentCollectionEmailOverrideTest < ActionDispatch::IntegrationTest
  extend Minitest::Spec::DSL
  include Capybara::DSL
  include Rails.application.routes.url_helpers
  include TaxonomyHelper

  describe "adding an email override" do
    let(:document_collection) { create(:draft_document_collection) }

    context "as a user with the email override editor permission" do
      let(:user_with_permission_to_override) { create(:writer, permissions: [User::Permissions::EMAIL_OVERRIDE_EDITOR]) }
      before do
        login_as(user_with_permission_to_override)
        stub_taxonomy_with_all_taxons
      end

      it "updates the taxonomy topic email override" do
        stub_publishing_api_has_item(content_id: root_taxon_content_id, title: root_taxon["title"])
        visit edit_admin_document_collection_path(document_collection)
        click_link "Email notifications"

        page.choose("Emails about the topic")
        select root_taxon["title"], from: "selected_taxon_content_id"
        page.check("Select this box to confirm you're happy with what you've selected.")
        click_button("Save")
        document_collection.reload
        assert_equal document_collection.taxonomy_topic_email_override, root_taxon_content_id
      end

      it "does not update taxonomy topic email if confirmation button is unchecked" do
        visit edit_admin_document_collection_path(document_collection)
        click_link "Email notifications"

        page.choose("Emails about the topic")
        select root_taxon["title"], from: "selected_taxon_content_id"
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

      it "shows the user a summary page if the document collection is in an unmodifiable state" do
        published_collection = create(:published_document_collection)
        taxons = { "title" => "Foo", "base_path" => "/foo", "content_id" => "123asd" }
        links = { "meets_user_needs" => %w[123] }
        stub_publishing_api_expanded_links_with_taxons(published_collection.content_id, [taxons])
        stub_publishing_api_has_links({ content_id: published_collection.content_id, links: })

        visit edit_admin_document_collection_path(published_collection)
        click_button "Create new edition"
        click_link "Email notifications"

        assert page.has_no_field?("override_email_subscriptions")
        assert page.has_content?("You cannot change the email notifications for this document collection.")
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
