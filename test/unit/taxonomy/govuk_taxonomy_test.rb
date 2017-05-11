require 'test_helper'

class Taxonomy::GovukTaxonomyTest < ActiveSupport::TestCase
  setup do
    @tree_builder_class = stub
    @test_adapter = stub

    @subject = Taxonomy::GovukTaxonomy.new(adapter: @test_adapter, tree_builder_class: @tree_builder_class)
  end

  test "#children" do
    tree_instance = stub(root_taxon: :root_taxon)
    setup_test_doubles_for_two_published_taxons(tree_instance)

    result = @subject.children
    assert_equal [:root_taxon, :root_taxon], result
  end

  test "#draft_child_taxons" do
    tree_instance = stub(root_taxon: :root_taxon)
    setup_test_doubles_including_one_visible_draft_taxon(tree_instance)

    result = @subject.draft_child_taxons
    assert_equal [:root_taxon], result
  end

  test "#all_taxons" do
    tree_instance = stub(root_taxon: stub(tree: [:sub_taxon]))
    setup_test_doubles_with_one_published_and_one_visible_draft(tree_instance)

    result = @subject.all_taxons
    assert_equal [:sub_taxon, :sub_taxon], result
  end

  class TestTaxon
    attr_reader :id

    def initialize
      @id = 5.times.map { |_| ('a'..'z').to_a.sample }.join
    end

    def to_h
      { "content_id" => id }
    end

    def tree
      "dummy_taxonomy_tree"
    end

    def expanded_links
      taxon_hash = self.to_h
      taxon_hash["expanded_links_hash"] = tree
      taxon_hash
    end
  end

  class VisibleDraftTaxon < TestTaxon
    def to_h
      {
        "content_id" => id,
        "details" => {
          "visible_to_departmental_editors" => true
        }
      }
    end
  end

  def setup_test_doubles_with_one_published_and_one_visible_draft(tree_instance)
    published_taxons = [TestTaxon.new]
    draft_taxons = [VisibleDraftTaxon.new]
    stub_test_adapter(published_taxons, draft_taxons, tree_instance)
  end

  def setup_test_doubles_including_one_visible_draft_taxon(tree_instance)
    published_taxons = [TestTaxon.new, TestTaxon.new]
    draft_taxons = [VisibleDraftTaxon.new, TestTaxon.new]
    stub_test_adapter(published_taxons, draft_taxons, tree_instance)
  end

  def setup_test_doubles_for_two_published_taxons(tree_instance)
    published_taxons = [TestTaxon.new, TestTaxon.new]
    draft_taxons = []
    stub_test_adapter(published_taxons, draft_taxons, tree_instance)
  end

  def stub_test_adapter(published_taxons, draft_taxons, tree_instance)
    setup_draft_taxons(draft_taxons)
    setup_published_taxons(published_taxons)

    draft_taxons.each { |taxon| setup_tree_data(taxon) }
    published_taxons.each { |taxon| setup_tree_data(taxon) }

    (published_taxons + draft_taxons).each do |taxon|
      @tree_builder_class.stubs(:new).with(taxon.expanded_links).returns(tree_instance)
    end
  end

  def setup_published_taxons(root_taxons)
    result = root_taxons.map(&:to_h)
    @test_adapter.stubs(:published_taxon_data).returns(result)
  end

  def setup_draft_taxons(root_taxons)
    result = root_taxons.map(&:to_h)
    @test_adapter.stubs(:draft_taxon_data).returns(result)
  end

  def setup_tree_data(dummy_taxon)
    @test_adapter.stubs(:tree_data).with(dummy_taxon.id).returns(dummy_taxon.tree)
  end
end
