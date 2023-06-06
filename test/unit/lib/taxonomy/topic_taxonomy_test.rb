require "test_helper"

class Taxonomy::TopicTaxonomyTest < ActiveSupport::TestCase
  include TaxonomyHelper

  def subject
    Taxonomy::TopicTaxonomy.new
  end

  test "#all_taxons" do
    redis_cache_has_taxons([build(:taxon_hash, content_id: "live_id", phase: "live"),
                            build(:taxon_hash, content_id: "alpha_id", phase: "alpha"),
                            build(:taxon_hash, content_id: "beta_id", phase: "beta")])
    assert_equal %w[live_id alpha_id beta_id], subject.all_taxons.map(&:content_id)
  end

  test "#visible_taxons" do
    redis_cache_has_taxons([build(:taxon_hash, content_id: "visible_id", visibility: true),
                            build(:taxon_hash, content_id: "visible_id", visibility: false)])
    assert_equal %w[visible_id], subject.visible_taxons.map(&:content_id)
  end

  test "#ordered_taxons are ordered by name" do
    redis_cache_has_taxons([build(:taxon_hash, title: "Cow", phase: "live"),
                            build(:taxon_hash, title: "Moose", phase: "alpha"),
                            build(:taxon_hash, title: "Alpha", phase: "alpha"),
                            build(:taxon_hash, title: "Donkey", phase: "beta"),
                            build(:taxon_hash, title: "Zebra", phase: "alpha"),
                            build(:taxon_hash, title: "Anteater", phase: "beta")])
    assert_equal %w[Alpha Anteater Cow Donkey Moose Zebra], subject.ordered_taxons.map(&:name)
  end

  test "#ordered_taxons_transformed are ordered by label" do
    redis_cache_has_taxons([build(:taxon_hash, title: "Cow", phase: "live"),
                            build(:taxon_hash, title: "Moose", phase: "alpha"),
                            build(:taxon_hash, title: "Alpha", phase: "alpha"),
                            build(:taxon_hash, title: "Donkey", phase: "beta"),
                            build(:taxon_hash, title: "Zebra", phase: "alpha"),
                            build(:taxon_hash, title: "Anteater", phase: "beta")])
    assert_equal(%w[Alpha Anteater Cow Donkey Moose Zebra], subject.ordered_taxons_transformed.map { |t| t[:label] })
  end

  test "#ordered_taxons_transformed are ordered by label and checked for preselected" do
    redis_cache_has_taxons([build(:taxon_hash, content_id: "cow", title: "Cow", phase: "live"),
                            build(:taxon_hash, content_id: "moose", title: "Moose", phase: "alpha"),
                            build(:taxon_hash, content_id: "alpha", title: "Alpha", phase: "alpha")])
    assert_equal([false, true, false], subject.ordered_taxons_transformed(%w[cow]).map { |t| t[:checked] })
  end
end
