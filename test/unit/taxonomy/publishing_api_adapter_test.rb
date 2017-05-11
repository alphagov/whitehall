require 'test_helper'

class Taxonomy::PublishingApiAdapterTest < ActiveSupport::TestCase
  def subject
    Taxonomy::PublishingApiAdapter.new
  end

  test "#published_taxon_data" do
    setup_published_taxons(["published_taxon"])
    result = subject.published_taxon_data
    assert result == ["published_taxon"]
  end

  test "#tree_data" do
    taxon_data = { "content_id" => "123" }
    setup_expanded_taxon_data(taxon_data)
    result = subject.tree_data("123")
    assert_equal taxon_data, result
  end

  test "#draft_taxon_data" do
    setup_published_taxons(["published"])
    setup_draft_taxons(["draft"])
    result = subject.draft_taxon_data
    assert_equal ["draft"], result
  end

  def setup_published_taxons(root_taxons)
    homepage_expanded_links = {
      "content_id" => Taxonomy::PublishingApiAdapter::HOMEPAGE_CONTENT_ID,
      "expanded_links" => {
        "root_taxons" => root_taxons
      }
    }
    publishing_api_has_expanded_links(homepage_expanded_links, with_drafts: false)
  end

  def setup_draft_taxons(root_taxons)
    homepage_expanded_links = {
      "content_id" => Taxonomy::PublishingApiAdapter::HOMEPAGE_CONTENT_ID,
      "expanded_links" => {
        "root_taxons" => root_taxons
      }
    }
    publishing_api_has_expanded_links(homepage_expanded_links, with_drafts: true)
  end

  def setup_expanded_taxon_data(taxon)
    publishing_api_has_expanded_links(taxon, with_drafts: false)
  end
end
