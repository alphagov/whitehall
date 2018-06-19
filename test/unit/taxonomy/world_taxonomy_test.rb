require 'test_helper'

class Taxonomy::WorldTaxonomyTest < ActiveSupport::TestCase
  include TaxonomyHelper

  def subject
    Taxonomy::WorldTaxonomy.new
  end

  test "#order of world taxons" do
    redis_cache_has_world_taxons(
      [
        build(:taxon_hash, title: 'France', children: [child_taxon]),
        build(:taxon_hash, title: 'Australia', children: [child_taxon, child_taxon]),
        build(:taxon_hash, title: 'News and events'),
        build(:taxon_hash, title: 'Birth, death and marriage abroad')
      ]
    )
    assert_equal ['Birth, death and marriage abroad', 'News and events', 'Australia', 'France'],
                 subject.all_world_taxons.map(&:name)
  end
end
