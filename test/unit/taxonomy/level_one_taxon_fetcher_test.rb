require 'test_helper'
require "gds_api/test_helpers/content_store"

class Taxonomy::LevelOneTaxonFetcherTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::ContentStore

  test "Fetches level one taxons" do
    content_item_hash = {
      "links" => {
        "level_one_taxons" => [
          {
            "base_path" => "/entering-staying-uk",
            "content_id" => "ba3a9702-da22-487f-86c1-8334a730e559",
            "title" => "Entering and staying in the UK",
            "details" =>
              { "visible_to_departmental_editors" => true },
            "phase" => "live",
            "links" => {},
          }
        ]
      }
    }
    content_store_has_item('/', content_item_hash)
    level_one_taxons = ::Taxonomy::LevelOneTaxonsFetcher.fetch
    assert_equal level_one_taxons.map(&:base_path), ["/entering-staying-uk"]
    assert_equal level_one_taxons.map(&:content_id), ["ba3a9702-da22-487f-86c1-8334a730e559"]
    assert_equal level_one_taxons.map(&:name), ["Entering and staying in the UK"]
    assert_equal level_one_taxons.map(&:visible_to_departmental_editors), [true]
    assert_equal level_one_taxons.map(&:phase), %w[live]
  end

  test 'omits non live' do
    content_item_hash = {
      "links" => {
        "level_one_taxons" => [
          {
            "title" => "live",
            "phase" => "live",
          },
          {
            "title" => "alpha",
            "phase" => "alpha",
          }
        ]
      }
    }
    content_store_has_item('/', content_item_hash)
    level_one_taxons = ::Taxonomy::LevelOneTaxonsFetcher.fetch
    assert_equal level_one_taxons.map(&:name), %w[live]
  end

  test "Fetches level one taxons in order of title" do
    content_item_hash = {
      "links" => {
        "level_one_taxons" => [
          {
            "title" => "a",
            "phase" => "live",
          },
          {
            "title" => "c",
            "phase" => "live",
          },
          {
            "title" => "b",
            "phase" => "live",
          },
        ]
      }
    }
    content_store_has_item('/', content_item_hash)
    level_one_taxons = ::Taxonomy::LevelOneTaxonsFetcher.fetch
    assert_equal level_one_taxons.map(&:name), %w[a b c]
  end

  test "There are no level one taxons so it returns an empty hash" do
    content_store_has_item('/', {})
    assert_empty ::Taxonomy::LevelOneTaxonsFetcher.fetch
  end

  test "There is no root taxon so it returns an empty hash" do
    content_store_does_not_have_item('/')
    assert_empty ::Taxonomy::LevelOneTaxonsFetcher.fetch
  end
end
