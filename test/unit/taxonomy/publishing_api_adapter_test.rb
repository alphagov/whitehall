require 'test_helper'

class Taxonomy::PublishingApiAdapterTest < ActiveSupport::TestCase
  def subject
    Taxonomy::PublishingApiAdapter.new
  end

  test "#published_taxon_data" do
    setup_published_taxons([published_taxon])
    result = subject.published_taxon_data
    assert_equal result, [published_taxon_tree]
  end

  test "#draft_taxon_data" do
    setup_published_taxons([published_taxon])
    setup_draft_taxons([visible_draft_taxon, draft_taxon])
    result = subject.draft_taxon_data
    assert_equal [visible_draft_taxon_tree], result
  end

  def published_taxon_tree
    published_taxon.tap do |taxon|
      taxon['expanded_links_hash'] = published_taxon
    end
  end

  def published_taxon
    { "content_id" => "published" }
  end

  def draft_taxon
    { "content_id" => "draft" }
  end

  def visible_draft_taxon_tree
    visible_draft_taxon.tap do |taxon|
      taxon['expanded_links_hash'] = visible_draft_taxon
    end
  end

  def visible_draft_taxon
    {
      "content_id" => "visible_and_draft",
      "details" => {
        "visible_to_departmental_editors" => true
      }
    }
  end

  def setup_published_taxons(level_one_taxons)
    homepage_expanded_links = {
      "content_id" => Taxonomy::PublishingApiAdapter::HOMEPAGE_CONTENT_ID,
      "expanded_links" => {
        "level_one_taxons" => level_one_taxons
      }
    }
    publishing_api_has_expanded_links(homepage_expanded_links, with_drafts: false)

    level_one_taxons.each do |taxon|
      publishing_api_has_expanded_links(taxon, with_drafts: true)
    end
  end

  def setup_draft_taxons(level_one_taxons)
    homepage_expanded_links = {
      "content_id" => Taxonomy::PublishingApiAdapter::HOMEPAGE_CONTENT_ID,
      "expanded_links" => {
        "level_one_taxons" => level_one_taxons
      }
    }
    publishing_api_has_expanded_links(homepage_expanded_links, with_drafts: true)

    level_one_taxons.each do |taxon|
      publishing_api_has_expanded_links(taxon, with_drafts: true)
    end
  end
end
