require "test_helper"

class Taxonomy::WorldTaxonomyTest < ActiveSupport::TestCase
  include TaxonomyHelper

  def subject
    Taxonomy::WorldTaxonomy.new
  end

  test "#order of world taxons" do
    redis_cache_has_world_taxons(
      [
        build(:taxon_hash, title: "France", children: [child_taxon]),
        build(:taxon_hash, title: "Australia", children: [child_taxon, child_taxon]),
        build(:taxon_hash, title: "News and events"),
        build(:taxon_hash, title: "Birth, death and marriage abroad"),
      ],
    )
    assert_equal ["Birth, death and marriage abroad", "News and events", "Australia", "France"],
                 subject.all_world_taxons.map(&:name)
  end

  test "#ordered_taxons_transformed are checked for preselected" do
    redis_cache_has_world_taxons(
      [
        build(:taxon_hash, content_id: "france", title: "France", children: [child_taxon]),
        build(:taxon_hash, content_id: "australia", title: "Australia", children: [child_taxon, child_taxon]),
        build(:taxon_hash, content_id: "news", title: "News and events"),
        build(:taxon_hash, content_id: "birth", title: "Birth, death and marriage abroad"),
      ],
    )
    assert_equal([false, true, false, false], subject.all_world_taxons_transformed(%w[news]).map { |t| t[:checked] })
  end
end
