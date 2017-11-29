require 'test_helper'

class EditionTaxonsFetcherTest < ActiveSupport::TestCase
  include TaxonomyHelper

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

    assert_equal links_fetcher.fetch.selected_taxon_paths, []
  end

  test "it returns '[]' if there are no taxons" do
    publishing_api_has_expanded_links(
      content_id:  "64aadc14-9bca-40d9-abb4-4f21f9792a05",
      expanded_links:  {}
    )

    links_fetcher = EditionTaxonsFetcher.new("64aadc14-9bca-40d9-abb4-4f21f9792a05")
    assert_equal links_fetcher.fetch.selected_taxon_paths, []
  end

  test "it returns a single taxon for the path if the taxon has no parents" do
    title = "Education, training and skills"

    publishing_api_has_expanded_links(
      content_id:  "64aadc14-9bca-40d9-abb4-4f21f9792a05",
      expanded_links:  {
        "taxons" => [
          {
            "title" => title,
            "content_id" => "aaaa",
            "links" => {},
          }
        ]
      }
    )
    stub_govuk_taxonomy_matching_published_taxons(['aaaa'], ['aaaa'])

    links_fetcher = EditionTaxonsFetcher.new("64aadc14-9bca-40d9-abb4-4f21f9792a05")
    assert_equal links_fetcher.fetch.selected_taxon_paths, [[{ title: title }]]
  end

  test "it returns both taxons for the path if the taxon has a parent but no grandparents" do
    parent_title = "Education, training and skills"
    title = "Further Education"

    publishing_api_has_expanded_links(
      content_id:  "64aadc14-9bca-40d9-abb4-4f21f9792a05",
      expanded_links:  {
        "taxons" => [
          {
            "title" => title,
            "content_id" => "aaaa",
            "links" => {
              "parent_taxons" => [
                {
                  "title" => parent_title,
                  "content_id" => "bbbb",
                  "links" => {}
                }
              ]
            }
          }
        ]
      }
    )
    stub_govuk_taxonomy_matching_published_taxons(['aaaa'], ['aaaa'])

    links_fetcher = EditionTaxonsFetcher.new("64aadc14-9bca-40d9-abb4-4f21f9792a05")
    assert_equal links_fetcher.fetch.selected_taxon_paths, [[{ title: parent_title }, { title: title }]]
  end

  test "it returns all taxons for the path if the taxon has a parent, grandparent, but no great-grandparents" do
    grandparent_title = "Education, training and skills"
    parent_title = "Further Education"
    title = "Student Finance"

    publishing_api_has_expanded_links(
      content_id:  "64aadc14-9bca-40d9-abb4-4f21f9792a05",
      expanded_links:  {
        "taxons" => [
          {
            "title" => title,
            "content_id" => "aaaa",
            "links" => {
              "parent_taxons" => [
                {
                  "title" => parent_title,
                  "content_id" => "bbbb",
                  "links" => {
                    "parent_taxons" => [
                      "title" => grandparent_title,
                      "content_id" => "cccc",
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
    stub_govuk_taxonomy_matching_published_taxons(['aaaa'], ['aaaa'])

    links_fetcher = EditionTaxonsFetcher.new("64aadc14-9bca-40d9-abb4-4f21f9792a05")
    assert_equal links_fetcher.fetch.selected_taxon_paths, [[{ title: grandparent_title }, { title: parent_title }, { title: title }]]
  end

  test "it returns paths for multiple taxons" do
    parent_education_title = "Education, training and skills"
    education_title = "Further Education"

    parent_taxes_title = "Money"
    taxes_title = "Paying taxes"

    publishing_api_has_expanded_links(
      content_id:  "64aadc14-9bca-40d9-abb4-4f21f9792a05",
      expanded_links:  {
        "taxons" => [
          {
            "title" => education_title,
            "content_id" => "aaaa",
            "links" => {
              "parent_taxons" => [
                {
                  "title" => parent_education_title,
                  "content_id" => "bbbb",
                  "links" => {}
                }
              ]
            }
          },
          {
            "title" => taxes_title,
            "content_id" => "cccc",
            "links" => {
              "parent_taxons" => [
                {
                  "title" => parent_taxes_title,
                  "content_id" => "dddd",
                  "links" => {}
                }
              ]
            }
          }
        ]
      }
    )
    stub_govuk_taxonomy_matching_published_taxons(%w[aaaa cccc], %w[aaaa cccc])

    links_fetcher = EditionTaxonsFetcher.new("64aadc14-9bca-40d9-abb4-4f21f9792a05")
    assert_equal(
      links_fetcher.fetch.selected_taxon_paths,
      [
        [{ title: parent_education_title }, { title: education_title }],
        [{ title: parent_taxes_title }, { title: taxes_title }],
      ]
    )
  end

  test "it uses the first taxon if there are multiple parents" do
    parent_education_title = "Education, training and skills"
    parent_work_title = "Work and pensions"
    education_title = "Further Education"

    publishing_api_has_expanded_links(
      content_id:  "64aadc14-9bca-40d9-abb4-4f21f9792a05",
      expanded_links:  {
        "taxons" => [
          {
            "title" => education_title,
            "content_id" => "aaaa",
            "links" => {
              "parent_taxons" => [
                {
                  "title" => parent_education_title,
                  "content_id" => "bbbb",
                  "links" => {}
                },
                {
                  "title" => parent_work_title,
                  "content_id" => "cccc",
                  "links" => {}
                },
              ]
            }
          }
        ]
      }
    )
    stub_govuk_taxonomy_matching_published_taxons(['aaaa'], ['aaaa'])

    links_fetcher = EditionTaxonsFetcher.new("64aadc14-9bca-40d9-abb4-4f21f9792a05")
    assert_equal links_fetcher.fetch.selected_taxon_paths, [[{ title: parent_education_title }, { title: education_title }]]
  end

  test "it only returns published or visible draft taxons" do
    published_title = "I am the published taxon"
    parent_published_title = "I am the parent of the published taxon"

    visible_draft_title = "I am the visible draft taxon"
    parent_visible_draft_title = "I am the parent of the visible draft taxon"

    invisible_draft_title = "I am the invisible draft taxon"
    parent_invisible_draft_title = "I am the parent of the invisible draft taxon"

    publishing_api_has_expanded_links(
      content_id:  "64aadc14-9bca-40d9-abb4-4f21f9792a05",
      expanded_links:  {
        "taxons" => [
          {
            "title" => published_title,
            "content_id" => "aaaa",
            "links" => {
              "parent_taxons" => [
                {
                  "title" => parent_published_title,
                  "content_id" => "bbbb",
                  "links" => {}
                },
              ]
            }
          },
          {
            "title" => visible_draft_title,
            "content_id" => "cccc",
            "links" => {
              "parent_taxons" => [
                {
                  "title" => parent_visible_draft_title,
                  "content_id" => "dddd",
                  "links" => {}
                },
              ]
            }
          },
          {
            "title" => invisible_draft_title,
            "content_id" => "eeee",
            "links" => {
              "parent_taxons" => [
                {
                  "title" => parent_invisible_draft_title,
                  "content_id" => "ffff",
                  "links" => {}
                },
              ]
            }
          }
        ]
      }
    )
    stub_govuk_taxonomy_matching_published_taxons(%w[aaaa cccc eeee], ["aaaa"])
    stub_govuk_taxonomy_matching_visible_draft_taxons(%w[aaaa cccc eeee], ["cccc"])

    links_fetcher = EditionTaxonsFetcher.new("64aadc14-9bca-40d9-abb4-4f21f9792a05")
    expected_taxon_paths = [
      [{ title: parent_published_title }, { title: published_title }],
      [{ title: parent_visible_draft_title }, { title: visible_draft_title }],
    ]

    assert_equal expected_taxon_paths, links_fetcher.fetch.selected_taxon_paths
  end
end
