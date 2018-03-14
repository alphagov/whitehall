require 'test_helper'

class Taxonomy::GovukTaxonomyTest < ActiveSupport::TestCase
  include TaxonomyHelper

  def subject
    Taxonomy::GovukTaxonomy.new
  end

  test "#live" do
    redis_cache_has_taxons([build(:taxon_hash, content_id: 'live_id', phase: 'live'),
                            build(:taxon_hash, phase: 'alpha')])
    assert_equal ['live_id'], subject.live.map(&:content_id)
  end

  test "#alpha_beta" do
    redis_cache_has_taxons([build(:taxon_hash, phase: 'live'),
                            build(:taxon_hash, content_id: 'alpha_id', phase: 'alpha'),
                            build(:taxon_hash, content_id: 'beta_id', phase: 'beta')])
    assert_equal %w[alpha_id beta_id], subject.alpha_beta.map(&:content_id)
  end

  test "#all_taxons" do
    redis_cache_has_taxons([build(:taxon_hash, content_id: 'live_id', phase: 'live'),
                            build(:taxon_hash, content_id: 'alpha_id', phase: 'alpha'),
                            build(:taxon_hash, content_id: 'beta_id', phase: 'beta')])
    assert_equal %w[live_id alpha_id beta_id], subject.all_taxons.map(&:content_id)
  end

  test "#visible_taxons" do
    redis_cache_has_taxons([build(:taxon_hash, content_id: 'visible_id', visibility: true),
                            build(:taxon_hash, content_id: 'visible_id', visibility: false),])
    assert_equal ['visible_id'], subject.visible_taxons.map(&:content_id)
  end

  test "#matching_against_published_taxons returns taxon content ids found in branch" do
    taxon_hash = {
      "base_path" => "/root-path",
      "content_id" => "root-taxon-in-tree",
      "title" => "I am the root taxon.",
      "expanded_links_hash" => {
        "expanded_links" => {
          "child_taxons" => [
            {
              "base_path" => "/child-path-one",
              "content_id" => "child-taxon-in-tree",
              "title" => "I am one child taxon.",
              "links" => {
                "child_taxons" => [
                  {
                    "base_path" => "/grand-child-path",
                    "content_id" => "grand-child-taxon-in-tree",
                    "title" => "I am the grand child taxon.",
                    "links" => {},
                  }
                ]
              }
            },
          ]
        }
      }
    }

    subject
      .stubs(:children)
      .returns([Taxonomy::Tree.new(taxon_hash).root_taxon])

    taxons = ['grand-child-taxon-in-tree', 'taxon-not-in-tree']

    assert_equal ['grand-child-taxon-in-tree'], subject.matching_against_published_taxons(taxons)
  end

  test "#matching_against_visible_draft_taxons returns taxon content ids found in branch" do
    taxon_hash = {
      "base_path" => "/draft-root-path",
      "content_id" => "root-taxon-in-tree",
      "title" => "I am the root draft taxon.",
      "expanded_links_hash" => {
        "expanded_links" => {
          "child_taxons" => [
            {
              "base_path" => "/draft-child-path-one",
              "content_id" => "draft-child-taxon-in-tree",
              "title" => "I am one child draft taxon.",
              "links" => {
                "child_taxons" => [
                  {
                    "base_path" => "draft-grand-child-path",
                    "content_id" => "draft-grand-child-taxon-in-tree",
                    "title" => "I am the grand child draft taxon.",
                    "links" => {},
                  }
                ]
              }
            },
          ]
        }
      }
    }

    subject
      .stubs(:draft_child_taxons)
      .returns([Taxonomy::Tree.new(taxon_hash).root_taxon])

    taxons = ['draft-grand-child-taxon-in-tree', 'draft-taxon-not-in-tree']

    assert_equal ['draft-grand-child-taxon-in-tree'], subject.matching_against_visible_draft_taxons(taxons)
  end
end
