require 'test_helper'

class ExpandedLinksFetcherTest < ActiveSupport::TestCase
  test "it returns '[]' if there are no taxons" do
    publishing_api_has_expanded_links(
      content_id:  "64aadc14-9bca-40d9-abb4-4f21f9792a05",
      expanded_links:  {}
    )

    links_fetcher = ExpandedLinksFetcher.new("64aadc14-9bca-40d9-abb4-4f21f9792a05")
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
            "links" => {}
          }
        ]
      }
    )

    links_fetcher = ExpandedLinksFetcher.new("64aadc14-9bca-40d9-abb4-4f21f9792a05")
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
            "links" => {
              "parent_taxons" => [
                {
                  "title" => parent_title,
                  "links" => {}
                }
              ]
            }
          }
        ]
      }
    )

    links_fetcher = ExpandedLinksFetcher.new("64aadc14-9bca-40d9-abb4-4f21f9792a05")
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
            "links" => {
              "parent_taxons" => [
                {
                  "title" => parent_title,
                  "links" => {
                    "parent_taxons" => [
                      "title" => grandparent_title,
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

    links_fetcher = ExpandedLinksFetcher.new("64aadc14-9bca-40d9-abb4-4f21f9792a05")
    assert_equal links_fetcher.fetch.selected_taxon_paths, [[{ title: grandparent_title }, { title: parent_title }, { title: title }]]
  end

  test "it returns paths for multiple taxons" do
    parent_title_1 = "Education, training and skills"
    title_1 = "Further Education"

    parent_title_2 = "Money"
    title_2 = "Paying taxes"

    publishing_api_has_expanded_links(
      content_id:  "64aadc14-9bca-40d9-abb4-4f21f9792a05",
      expanded_links:  {
        "taxons" => [
          {
            "title" => title_1,
            "links" => {
              "parent_taxons" => [
                {
                  "title" => parent_title_1,
                  "links" => {}
                }
              ]
            }
          },
          {
            "title" => title_2,
            "links" => {
              "parent_taxons" => [
                {
                  "title" => parent_title_2,
                  "links" => {}
                }
              ]
            }
          }
        ]
      }
    )

    links_fetcher = ExpandedLinksFetcher.new("64aadc14-9bca-40d9-abb4-4f21f9792a05")
    assert_equal(
      links_fetcher.fetch.selected_taxon_paths,
      [
        [{ title: parent_title_1 }, { title: title_1 }],
        [{ title: parent_title_2 }, { title: title_2 }],
      ]
    )
  end

  test "it uses the first taxon if there are multiple parents" do
    parent_title_1 = "Education, training and skills"
    parent_title_2 = "Work and pensions"
    title = "Further Education"

    publishing_api_has_expanded_links(
      content_id:  "64aadc14-9bca-40d9-abb4-4f21f9792a05",
      expanded_links:  {
        "taxons" => [
          {
            "title" => title,
            "links" => {
              "parent_taxons" => [
                {
                  "title" => parent_title_1,
                  "links" => {}
                },
                {
                  "title" => parent_title_2,
                  "links" => {}
                },
              ]
            }
          }
        ]
      }
    )

    links_fetcher = ExpandedLinksFetcher.new("64aadc14-9bca-40d9-abb4-4f21f9792a05")
    assert_equal links_fetcher.fetch.selected_taxon_paths, [[{ title: parent_title_1 }, { title: title }]]
  end
end
