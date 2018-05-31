require 'test_helper'

class Taxonomy::PublishingApiAdapterTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  def subject
    Taxonomy::PublishingApiAdapter.new
  end

  describe "#taxon_data" do
    test "base hash" do
      setup_taxons
      assert_equal %w[taxon1 taxon2], (subject.taxon_data.map { |t| t['title'] })
    end

    test "expanded links" do
      setup_taxons
      assert_equal %w[child1 child2],
                   (subject.taxon_data.first.dig('expanded_links_hash', 'expanded_links', 'child_taxons').map { |t| t['title'] })
    end
  end

  describe "#world_taxon_data" do
    test "base hash" do
      setup_world_taxons
      assert_equal %w[World], (subject.world_taxon_data.map { |t| t['title'] })
    end

    test "#expanded links" do
      setup_world_taxons
      assert_equal %w(country-1 country-2),
                   (subject.world_taxon_data.first.dig('expanded_links_hash', 'expanded_links', 'child_taxons').map { |t| t['title'] })
    end
  end

private

  def level_one_taxons
    [taxon("taxon1"), taxon("taxon2")]
  end

  def homepage_expanded_links
    {
      "content_id" => Taxonomy::PublishingApiAdapter::HOMEPAGE_CONTENT_ID,
      "expanded_links" => {
          "level_one_taxons" => level_one_taxons
      }
    }
  end

  def taxon(id)
    {
        "content_id" => id.to_s,
        "title" => id.to_s
    }
  end

  def expanded_link(content_id, taxons)
    {
        "content_id" => content_id,
        "expanded_links" => {
          "child_taxons" => taxons
        }
    }
  end

  def setup_taxons
    publishing_api_has_expanded_links(homepage_expanded_links, with_drafts: false)

    level_one_taxons.each do |taxon|
      expanded_link_hash = expanded_link(taxon['content_id'], [taxon("child1"), taxon("child2")])
      publishing_api_has_expanded_links(expanded_link_hash, with_drafts: false)
    end
  end

  def setup_world_taxons
    publishing_api_has_item(
      content_id: Taxonomy::PublishingApiAdapter::WORLD_CONTENT_ID,
      title: "World",
      base_path: "/world/all"
    )

    world_content_id = Taxonomy::PublishingApiAdapter::WORLD_CONTENT_ID

    expanded_link_hash = expanded_link(world_content_id, [taxon("country-1"), taxon("country-2")])
    publishing_api_has_expanded_links(expanded_link_hash, with_drafts: false)
  end
end
