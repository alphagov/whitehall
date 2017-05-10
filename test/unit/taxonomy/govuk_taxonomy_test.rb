require 'test_helper'

class Taxonomy::GovukTaxonomyTest < ActiveSupport::TestCase
  setup do
    @tree = stub(root_taxon: :root_taxon)
    @tree_class = Taxonomy::Tree = stub(new: @tree)

    @published_taxon_a = taxon(1)
    @published_taxon_b = taxon(2)
    @visible_draft_taxon = visible_draft_taxon(3)
    @draft_taxon = taxon(4)
  end

  test "#children" do
    published_taxons = [@published_taxon_a, @published_taxon_b]
    stub_publishing_api(published_taxons, [])

    @tree_class.expects(:new).with(expanded_links_hash_for_taxon_1).returns(@tree)
    @tree_class.expects(:new).with(expanded_links_hash_for_taxon_2).returns(@tree)

    result = subject.children
    assert_equal [:root_taxon, :root_taxon], result
  end

  test "#draft_child_taxons" do
    published_taxons = [@published_taxon_a]
    draft_taxons = [@visible_draft_taxon, @draft_taxon]
    stub_publishing_api(published_taxons, draft_taxons)

    @tree_class.expects(:new).with(expanded_links_hash_for_taxon_3).returns(@tree)

    result = subject.draft_child_taxons
    assert_equal [:root_taxon], result
  end

  test "#all_taxons" do
    tree = stub(root_taxon: stub(tree: [:sub_taxon]))

    draft_taxons = [@visible_draft_taxon]
    published_taxons = [@published_taxon_a]

    stub_publishing_api(published_taxons, draft_taxons)

    @tree_class.expects(:new).with(expanded_links_hash_for_taxon_1).returns(tree)
    @tree_class.expects(:new).with(expanded_links_hash_for_taxon_3).returns(tree)

    result = subject.all_taxons
    assert_equal [:sub_taxon, :sub_taxon], result
  end

  def subject
    Taxonomy::GovukTaxonomy.new
  end

  def stub_publishing_api(published_taxons, draft_taxons)
    setup_draft_taxons(draft_taxons)
    setup_published_taxons(published_taxons)

    draft_taxons.each { |taxon| setup_expanded_taxon_data(taxon) }
    published_taxons.each { |taxon| setup_expanded_taxon_data(taxon) }
  end

  def taxon(id)
    { "content_id" => id.to_s }
  end

  def expanded_links_hash(taxon)
    taxon.merge("expanded_links_hash" => taxon)
  end

  def expanded_links_hash_for_taxon_1
    expanded_links_hash(@published_taxon_a)
  end

  def expanded_links_hash_for_taxon_2
    expanded_links_hash(@published_taxon_b)
  end

  def expanded_links_hash_for_taxon_3
    expanded_links_hash(@visible_draft_taxon)
  end

  def visible_draft_taxon(id)
    {
      "content_id" => id.to_s,
      "details" => {
        "visible_to_departmental_editors" => true
      }
    }
  end

  def setup_published_taxons(root_taxons)
    homepage_expanded_links = {
      content_id: Taxonomy::GovukTaxonomy::HOMEPAGE_CONTENT_ID,
      expanded_links: {
        root_taxons: root_taxons
      }
    }
    publishing_api_has_expanded_links(homepage_expanded_links, with_drafts: false)
  end

  def setup_draft_taxons(root_taxons)
    homepage_expanded_links = {
      content_id: Taxonomy::GovukTaxonomy::HOMEPAGE_CONTENT_ID,
      expanded_links: {
        root_taxons: root_taxons
      }
    }
    publishing_api_has_expanded_links(homepage_expanded_links, with_drafts: true)
  end

  def setup_expanded_taxon_data(taxon)
    publishing_api_has_expanded_links(taxon, with_drafts: false)
  end
end
