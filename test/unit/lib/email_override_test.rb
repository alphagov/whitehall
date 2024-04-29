require "test_helper"

class EmailOverrideTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL
  include TaxonomyHelper
  setup do
    # stub_any_publishing_api_call
    stub_taxonomy_with_selected_taxons
    stub_taxonomy_with_all_taxons
    stub_publishing_api_has_item(content_id: work_taxon_content_id, title: work_taxon_parent["title"])

    @document_collection = create(:document_collection, :draft)
    # stub_taxonomy_with_all_taxons
  end

  test "changes the email overide attribute to a content_id" do
    taxons = { "title" => "title", "base_path" => "/foo", "content_id" => "work_taxon_content_id" }
    links = { "meets_user_needs" => %w[123] }
    stub_publishing_api_expanded_links_with_taxons(@document_collection.content_id, [taxons])
    stub_publishing_api_has_links({ content_id: @document_collection.content_id, links: })

    email_overrider = EmailOveride::EmailOverride.new(document_collection_id: @document_collection.id, taxon_content_id: work_taxon_content_id, dry_run: false)

    # Rake.application.invoke_task("set_email_override:real[#{document_collection.id},#{root_taxon_content_id}]")
    email_overrider.call
    puts @document_collection.taxonomy_topic_email_override

    assert_equal work_taxon_content_id, DocumentCollection.find(@document_collection.id).taxonomy_topic_email_override
  end

  test "shows an error if the taxon does not exist" do
    taxon_content_id = "xxx-xxx-xxx"

    assert_raises(StandardError, "Cannot find a taxon with the content ID") do
      Rake.application.invoke_task("set_email_override:real[#{@document_collection.id} #{taxon_content_id}]")
    end
  end

  test "shows an error if the document has been previously published" do
    document_collection = create(:document_collection, :published)

    assert_raises(StandardError, "This document has been published previously. Email overrides can only be changed when the document has no been previously published") do
      Rake.application.invoke_task("set_email_override[#{document_collection.id} #{root_taxon_content_id}]")
    end
  end
end
