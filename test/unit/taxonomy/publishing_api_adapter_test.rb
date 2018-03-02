require 'test_helper'

class Taxonomy::PublishingApiAdapterTest < ActiveSupport::TestCase
  def subject
    Taxonomy::PublishingApiAdapter.new
  end

  test "#published_taxon_data" do
    setup_taxons([visible_published_taxon, not_visible_published_taxon], with_drafts: false)
    setup_taxons([visible_draft_taxon, not_visible_draft_taxon, visible_published_taxon, not_visible_published_taxon], with_drafts: true)
    result = subject.published_taxon_data
    assert_same_elements result, [taxon_tree(visible_published_taxon), taxon_tree(not_visible_published_taxon)]
  end

  test "#draft_taxon_data" do
    setup_taxons([visible_published_taxon, not_visible_published_taxon], with_drafts: false)
    setup_taxons([visible_draft_taxon, not_visible_draft_taxon, visible_published_taxon, not_visible_published_taxon], with_drafts: true)
    result = subject.draft_taxon_data
    assert_same_elements [taxon_tree(visible_draft_taxon)], result
  end

  def taxon_tree(taxon)
    taxon.tap do |t|
      t['expanded_links_hash'] = taxon.dup
    end
  end

  def visible_published_taxon
    {
      "content_id" => "published_visible",
      "details" => {
        "visible_to_departmental_editors" => true
      }
    }
  end

  def not_visible_published_taxon
    {
      "content_id" => "published",
      "details" => {
        "visible_to_departmental_editors" => false
      }
    }
  end

  def not_visible_draft_taxon
    {
      "content_id" => "draft",
      "details" => {
        "visible_to_departmental_editors" => false
      }
    }
  end

  def visible_draft_taxon
    {
      "content_id" => "draft_visible",
      "details" => {
        "visible_to_departmental_editors" => true
      }
    }
  end

  def setup_taxons(level_one_taxons, with_drafts: false)
    homepage_expanded_links = {
      "content_id" => Taxonomy::PublishingApiAdapter::HOMEPAGE_CONTENT_ID,
      "expanded_links" => {
        "level_one_taxons" => level_one_taxons
      }
    }
    publishing_api_has_expanded_links(homepage_expanded_links, with_drafts: with_drafts)

    level_one_taxons.each do |taxon|
      publishing_api_has_expanded_links(taxon, with_drafts: with_drafts)
    end
  end
end
