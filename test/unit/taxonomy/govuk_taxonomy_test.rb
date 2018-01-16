require 'test_helper'

class Taxonomy::GovukTaxonomyTest < ActiveSupport::TestCase
  setup do
    @test_adapter = stub
    @taxon_tree = stub
    @taxon = stub(root_taxon: @taxon_tree)
    @tree_builder_class = stub(new: @taxon)

    @subject = Taxonomy::GovukTaxonomy.new(adapter: @test_adapter, tree_builder_class: @tree_builder_class)
  end

  test "#children" do
    @test_adapter.stubs(:published_taxon_data).returns(%i[taxon taxon])
    result = @subject.children
    assert_equal result, [@taxon_tree, @taxon_tree]
  end

  test "#draft_child_taxons" do
    @test_adapter.stubs(:draft_taxon_data).returns(%i[taxon taxon])
    result = @subject.draft_child_taxons
    assert_equal result, [@taxon_tree, @taxon_tree]
  end

  test "#all_taxons" do
    @test_adapter.stubs(:published_taxon_data).returns(%i[taxon taxon])
    @test_adapter.stubs(:draft_taxon_data).returns(%i[taxon taxon])
    @taxon_tree.stubs(:tree).returns(:root_taxon)
    result = @subject.all_taxons
    assert_equal result, %i[root_taxon root_taxon root_taxon root_taxon]
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

    @subject
      .stubs(:children)
      .returns([Taxonomy::Tree.new(taxon_hash).root_taxon])

    taxons = ['grand-child-taxon-in-tree', 'taxon-not-in-tree']

    assert_equal ['grand-child-taxon-in-tree'], @subject.matching_against_published_taxons(taxons)
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

    @subject
      .stubs(:draft_child_taxons)
      .returns([Taxonomy::Tree.new(taxon_hash).root_taxon])

    taxons = ['draft-grand-child-taxon-in-tree', 'draft-taxon-not-in-tree']

    assert_equal ['draft-grand-child-taxon-in-tree'], @subject.matching_against_visible_draft_taxons(taxons)
  end
end
