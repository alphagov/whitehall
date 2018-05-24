require 'test_helper'

class EditionTaxonsFetcherTest < ActiveSupport::TestCase
  include TaxonomyHelper

  setup do
    stub_taxonomy_with_world_taxons
  end

  test "it returns '[]' if there are no expanded_links" do
    content_id = "64aadc14-9bca-40d9-abb4-4f21f9792a05"

    body = {
      "error" => {
        "code" => 404,
        "message" => "Could not find link set with content_id: #{content_id}"
      }
    }.to_json

    stub_request(:get, %r{.*/v2/expanded-links/#{content_id}.*})
      .to_return(body: body, status: 404)

    links_fetcher = EditionTaxonsFetcher.new(content_id)

    assert_equal [], links_fetcher.fetch
  end

  test "it returns '[]' if there are no taxons" do
    publishing_api_has_expanded_links(
      content_id:  "64aadc14-9bca-40d9-abb4-4f21f9792a05",
      expanded_links:  {}
    )

    links_fetcher = EditionTaxonsFetcher.new("64aadc14-9bca-40d9-abb4-4f21f9792a05")
    assert_equal [], links_fetcher.fetch
  end

  test "it returns a taxon without a parent" do
    title = "Education, training and skills"

    publishing_api_has_expanded_links(
      content_id:  "64aadc14-9bca-40d9-abb4-4f21f9792a05",
      expanded_links:  {
        "taxons" => [
          {
            "title" => title,
            "content_id" => "aaaa",
            "base_path" => "/i-am-a-taxon",
            "details" => { "visible_to_departmental_editors" => true },
            "links" => {},
          }
        ]
      }
    )
    taxons = EditionTaxonsFetcher.new("64aadc14-9bca-40d9-abb4-4f21f9792a05").fetch
    assert_equal 'aaaa', taxons.first.content_id
  end

  test "it returns a taxon with a parent" do
    publishing_api_has_expanded_links(
      content_id:  "64aadc14-9bca-40d9-abb4-4f21f9792a05",
      expanded_links:  {
        "taxons" => [
          {
            "title" => "Further Education",
            "content_id" => "aaaa",
            "base_path" => "/i-am-a-taxon",
            "details" => { "visible_to_departmental_editors" => true },
            "links" => {
              "parent_taxons" => [
                {
                  "title" => "Education, training and skills",
                  "content_id" => "bbbb",
                  "base_path" => "/i-am-a-parent-taxon",
                  "details" => { "visible_to_departmental_editors" => true },
                  "links" => {}
                }
              ]
            }
          }
        ]
      }
    )
    taxons = EditionTaxonsFetcher.new("64aadc14-9bca-40d9-abb4-4f21f9792a05").fetch
    assert_equal 'aaaa', taxons.first.content_id
    assert_equal 'bbbb', taxons.first.parent_node.content_id
  end

  test "it returns a taxon with parent and grandparent" do
    publishing_api_has_expanded_links(
      content_id:  "64aadc14-9bca-40d9-abb4-4f21f9792a05",
      expanded_links:  {
        "taxons" => [
          {
            "title" => "Student Finance",
            "content_id" => "aaaa",
            "base_path" => "/i-am-a-taxon",
            "details" => { "visible_to_departmental_editors" => true },
            "links" => {
              "parent_taxons" => [
                {
                  "title" => "Further Education",
                  "content_id" => "bbbb",
                  "base_path" => "/i-am-a-parent-taxon",
                  "details" => { "visible_to_departmental_editors" => true },
                  "links" => {
                    "parent_taxons" => [
                      "title" => "Education, training and skills",
                      "content_id" => "cccc",
                      "base_path" => "/i-am-a-grand-parent-taxon",
                      "details" => { "visible_to_departmental_editors" => true },
                      "links" => {}
                    ]
                  }
                }
              ]
            }
          }
        ]
      }
    )
    taxons = EditionTaxonsFetcher.new("64aadc14-9bca-40d9-abb4-4f21f9792a05").fetch
    assert_equal 'aaaa', taxons.first.content_id
    assert_equal 'bbbb', taxons.first.parent_node.content_id
    assert_equal 'cccc', taxons.first.parent_node.parent_node.content_id
  end

  test "it returns paths for multiple taxons" do
    publishing_api_has_expanded_links(
      content_id:  "64aadc14-9bca-40d9-abb4-4f21f9792a05",
      expanded_links:  {
        "taxons" => [
          {
            "title" => "Further Education",
            "content_id" => "aaaa",
            "base_path" => "/i-am-a-taxon",
            "details" => { "visible_to_departmental_editors" => true },
            "links" => {
              "parent_taxons" => [
                {
                  "title" => "Education, training and skills",
                  "content_id" => "bbbb",
                  "base_path" => "/i-am-a-parent-taxon",
                  "details" => { "visible_to_departmental_editors" => true },
                  "links" => {}
                }
              ]
            }
          },
          {
            "title" => "Paying taxes",
            "content_id" => "cccc",
            "base_path" => "/i-am-another-taxon",
            "details" => { "visible_to_departmental_editors" => true },
            "links" => {
              "parent_taxons" => [
                {
                  "title" => "Money",
                  "content_id" => "dddd",
                  "base_path" => "/i-am-another-parent-taxon",
                  "details" => { "visible_to_departmental_editors" => true },
                  "links" => {}
                }
              ]
            }
          }
        ]
      }
    )
    taxons = EditionTaxonsFetcher.new("64aadc14-9bca-40d9-abb4-4f21f9792a05").fetch
    assert_equal 2, taxons.count
    assert_equal "aaaa", taxons.first.content_id
    assert_equal "bbbb", taxons.first.parent_node.content_id
    assert_equal "cccc", taxons.last.content_id
    assert_equal "dddd", taxons.last.parent_node.content_id
  end

  test "it sets the first parent taxon if there are multiple parents" do
    publishing_api_has_expanded_links(
      content_id:  "64aadc14-9bca-40d9-abb4-4f21f9792a05",
      expanded_links:  {
        "taxons" => [
          {
            "title" => "Further Education",
            "content_id" => "aaaa",
            "base_path" => "/i-am-a-taxon",
            "details" => { "visible_to_departmental_editors" => true },
            "links" => {
              "parent_taxons" => [
                {
                  "title" => "Education, training and skills",
                  "content_id" => "bbbb",
                  "base_path" => "/i-am-a-parent-taxon",
                  "details" => { "visible_to_departmental_editors" => true },
                  "links" => {}
                },
                {
                  "title" => "Work and pensions",
                  "content_id" => "cccc",
                  "base_path" => "/i-am-another-parent-taxon",
                  "details" => { "visible_to_departmental_editors" => true },
                  "links" => {}
                },
              ]
            }
          }
        ]
      }
    )
    taxons = EditionTaxonsFetcher.new("64aadc14-9bca-40d9-abb4-4f21f9792a05").fetch
    assert_equal "aaaa", taxons.first.content_id
    assert_equal "bbbb", taxons.first.parent_node.content_id
  end

  test "it only returns published or visible draft taxons" do
    publishing_api_has_expanded_links(
      content_id:  "64aadc14-9bca-40d9-abb4-4f21f9792a05",
      expanded_links:  {
        "taxons" => [
          {
            "title" => "I am the published taxon",
            "content_id" => "aaaa",
            "base_path" => "/i-am-a-taxon",
            "details" => { "visible_to_departmental_editors" => true },
            "links" => {
              "parent_taxons" => [
                {
                  "title" => "I am the parent of the published taxon",
                  "content_id" => "bbbb",
                  "base_path" => "/i-am-a-parent-taxon",
                  "details" => { "visible_to_departmental_editors" => true },
                  "links" => {}
                },
              ]
            }
          },
          {
            "title" => "I am the visible draft taxon",
            "content_id" => "cccc",
            "base_path" => "/i-am-another-taxon",
            "details" => { "visible_to_departmental_editors" => true },
            "links" => {
              "parent_taxons" => [
                {
                  "title" => "I am the parent of the visible draft taxon",
                  "content_id" => "dddd",
                  "base_path" => "/i-am-another-parent-taxon",
                  "details" => { "visible_to_departmental_editors" => true },
                  "links" => {}
                },
              ]
            }
          },
          {
            "title" => "I am the invisible draft taxon",
            "content_id" => "eeee",
            "base_path" => "/i-am-yet-another-taxon",
            "details" => { "visible_to_departmental_editors" => true },
            "links" => {
              "parent_taxons" => [
                {
                  "title" => "I am the parent of the invisible draft taxon",
                  "content_id" => "ffff",
                  "base_path" => "/i-am-yet-another-parent-taxon",
                  "details" => { "visible_to_departmental_editors" => false },
                  "links" => {}
                },
              ]
            }
          }
        ]
      }
    )

    taxons = EditionTaxonsFetcher.new("64aadc14-9bca-40d9-abb4-4f21f9792a05").fetch
    assert_equal %w[aaaa cccc], taxons.map(&:content_id)
  end

  test "it gets world taxons tagged to the edition" do
    publishing_api_has_expanded_links(
      content_id:  "64aadc14-9bca-40d9-abb4-4f21f9792a05",
      expanded_links:  {
        "taxons" => [
          {
            "title" => "I am the published taxon",
            "content_id" => "published-taxon",
            "base_path" => "/i-am-a-taxon",
            "details" => { "visible_to_departmental_editors" => true },
            "links" => {
              "parent_taxons" => [
                {
                  "title" => "I am the parent of the published taxon",
                  "content_id" => "bbbb",
                  "base_path" => "/i-am-a-parent-taxon",
                  "details" => { "visible_to_departmental_editors" => true },
                  "links" => {}
                },
              ]
            }
          },
          {
            "title" => "I am the world taxon",
            "content_id" => "world-taxon",
            "base_path" => "/world/i-am-a-world-taxon",
            "details" => { "visible_to_departmental_editors" => true },
            "links" => {
              "parent_taxons" => [
                {
                  "title" => "I am the parent of the visible draft taxon",
                  "content_id" => "dddd",
                  "base_path" => "/world/all",
                  "details" => { "visible_to_departmental_editors" => true },
                  "links" => {}
                },
              ]
            }
          }
        ]
      }
    )
    redis_cache_has_world_taxons([build(:taxon_hash, content_id: 'world-taxon')])

    redis_cache_has_world_taxons([build(:taxon_hash, content_id: 'world-taxon')])

    taxons = EditionTaxonsFetcher.new("64aadc14-9bca-40d9-abb4-4f21f9792a05").fetch_world_taxons
    assert_equal %w[world-taxon], taxons.map(&:content_id)
  end
end
