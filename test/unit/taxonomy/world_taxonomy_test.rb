require 'test_helper'

class Taxonomy::WorldTaxonomyTest < ActiveSupport::TestCase
  include TaxonomyHelper

  def subject
    Taxonomy::WorldTaxonomy.new
  end

  test "#world_taxons" do
    redis_cache_has_world_taxons(
      [
        build(:taxon_hash, content_id: 'content_id_1'),
        build(:taxon_hash, content_id: 'content_id_2'),
        build(:taxon_hash, content_id: 'content_id_3')
      ]
    )
    assert_equal %w[content_id_1 content_id_2 content_id_3], subject.all_world_taxons.map(&:content_id)
  end
end
