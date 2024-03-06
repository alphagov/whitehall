require "test_helper"
require "capybara/rails"

class DocumentCollectionEmailOverrideTest < ActionDispatch::IntegrationTest
  extend Minitest::Spec::DSL
  include Capybara::DSL
  include Rails.application.routes.url_helpers
  include TaxonomyHelper

  describe "adding an email override" do
    let(:user) { create(:writer) }
    before do
      login_as(user)
      stub_taxonomy_with_selected_taxons
    end

    context "the document collection has an email override set" do
      it "shows the user a summary page" do
        published_collection = create(:published_document_collection, taxonomy_topic_email_override: work_taxon_content_id)
        stub_publishing_api_has_item(content_id: work_taxon_content_id, title: work_taxon_parent["title"])
        taxons = { "title" => "title", "base_path" => "/foo", "content_id" => "work_taxon_content_id" }
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

    context "the document collection has no email override set" do
      it "shows the user a summary page" do
        published_collection = create(:published_document_collection)
        taxons = { "title" => "Foo", "base_path" => "/foo", "content_id" => "123asd" }
        links = { "meets_user_needs" => %w[123] }
        stub_publishing_api_expanded_links_with_taxons(published_collection.content_id, [taxons])
        stub_publishing_api_has_links({ content_id: published_collection.content_id, links: })

        visit edit_admin_document_collection_path(published_collection)
        click_button "Create new edition"
        assert page.has_no_link?("Email notifications")
      end
    end
  end
end
