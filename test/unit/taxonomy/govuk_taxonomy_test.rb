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
end
