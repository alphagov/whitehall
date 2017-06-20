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
    @test_adapter.stubs(:published_taxon_data).returns([:taxon, :taxon])
    result = @subject.children
    assert_equal result, [@taxon_tree, @taxon_tree]
  end

  test "#draft_child_taxons" do
    @test_adapter.stubs(:draft_taxon_data).returns([:taxon, :taxon])
    result = @subject.draft_child_taxons
    assert_equal result, [@taxon_tree, @taxon_tree]
  end

  test "#all_taxons" do
    @test_adapter.stubs(:published_taxon_data).returns([:taxon, :taxon])
    @test_adapter.stubs(:draft_taxon_data).returns([:taxon, :taxon])
    @taxon_tree.stubs(:tree).returns(:root_taxon)
    result = @subject.all_taxons
    assert_equal result, [:root_taxon, :root_taxon, :root_taxon, :root_taxon]
  end
end
