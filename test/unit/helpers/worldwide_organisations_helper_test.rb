require "test_helper"

class WorldwideOrganisationsHelperTest < ActionView::TestCase
  test "path returns /government/world/organisations/<slug> for a non test org" do
    location = create(:world_location, slug: "india")
    org = create(
      :worldwide_organisation,
      slug: "none-test-slug",
      world_locations: [
        location
      ]
    )

    assert_equal(
      "/government/world/organisations/none-test-slug",
      worldwide_organisation_path(org)
    )
  end

  test "url returns <host>/government/world/organisations/slug for a non test org" do
    location = create(:world_location, slug: "india")
    org = create(
      :worldwide_organisation,
      slug: "none-test-slug",
      world_locations: [
        location
      ]
    )

    assert_equal(
      "http://test.host/government/world/organisations/none-test-slug",
      worldwide_organisation_url(org)
    )
  end

  test "path returns /government/world/<location>/<slug> for an org under A/B test" do
    location = create(:world_location, slug: "india")
    org = create(
      :worldwide_organisation,
      slug: "british-high-commission-new-delhi",
      world_locations: [
        location
      ]
    )

    assert_equal(
      "/government/world/india/british-high-commission-new-delhi",
      worldwide_organisation_path(org)
    )
  end

  test "url returns /government/world/<location>/<slug> for an org under A/B test" do
    location = create(:world_location, slug: "india")
    org = create(
      :worldwide_organisation,
      slug: "british-high-commission-new-delhi",
      world_locations: [
        location
      ]
    )

    assert_equal(
      "http://test.host/government/world/india/british-high-commission-new-delhi",
      worldwide_organisation_url(org)
    )
  end
end
