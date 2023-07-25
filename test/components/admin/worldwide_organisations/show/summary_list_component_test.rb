# frozen_string_literal: true

require "test_helper"

class Admin::WorldwideOrganisations::Show::SummaryListComponentTest < ViewComponent::TestCase
  include Rails.application.routes.url_helpers

  test "renders the correct default items" do
    worldwide_organisation = build_stubbed(:worldwide_organisation, logo_formatted_name: nil)
    render_inline(Admin::WorldwideOrganisations::Show::SummaryListComponent.new(worldwide_organisation:))

    assert_selector ".govuk-summary-list__row", count: 1
    assert_selector ".govuk-summary-list__key", text: "Name"
    assert_selector ".govuk-summary-list__value", text: worldwide_organisation.name
    assert_link("Edit", href: edit_admin_worldwide_organisation_path(worldwide_organisation))
  end

  test "renders the correct items when all fields are completed and only 1 world location & sponsoring organisation" do
    world_location = build_stubbed(:world_location)
    sponsoring_organisation = build_stubbed(:organisation)
    news_image = build_stubbed(:default_news_organisation_image_data)
    worldwide_organisation = build_stubbed(
      :worldwide_organisation,
      logo_formatted_name: "Optional log formatted name",
      world_locations: [world_location],
      sponsoring_organisations: [sponsoring_organisation],
      default_news_image: news_image,
    )

    render_inline(Admin::WorldwideOrganisations::Show::SummaryListComponent.new(worldwide_organisation:))

    assert_selector ".govuk-summary-list__row", count: 5
    assert_selector ".govuk-summary-list__row:nth-child(1) .govuk-summary-list__key", text: "Name"
    assert_selector ".govuk-summary-list__row:nth-child(1) .govuk-summary-list__value", text: worldwide_organisation.name
    assert_selector ".govuk-summary-list__row:nth-child(2) .govuk-summary-list__key", text: "World location"
    assert_selector ".govuk-summary-list__row:nth-child(2) .govuk-summary-list__value", text: world_location.name
    assert_selector ".govuk-summary-list__row:nth-child(3) .govuk-summary-list__key", text: "Sponsoring organisation"
    assert_selector ".govuk-summary-list__row:nth-child(3) .govuk-summary-list__value", text: sponsoring_organisation.name
    assert_selector ".govuk-summary-list__row:nth-child(4) .govuk-summary-list__key", text: "Logo formatted name"
    assert_selector ".govuk-summary-list__row:nth-child(4) .govuk-summary-list__value", text: worldwide_organisation.logo_formatted_name
    assert_selector ".govuk-summary-list__row:nth-child(5) .govuk-summary-list__key", text: "Default news image"
    assert_selector ".govuk-summary-list__row:nth-child(5) .govuk-summary-list__value img[src='#{news_image.file.url(:s300)}']"
  end

  test "renders the correct items when the worldwide organisation has multiple world locations" do
    world_location1 = build_stubbed(:world_location)
    world_location2 = build_stubbed(:world_location)
    worldwide_organisation = build_stubbed(
      :worldwide_organisation,
      logo_formatted_name: nil,
      world_locations: [world_location1, world_location2],
    )

    render_inline(Admin::WorldwideOrganisations::Show::SummaryListComponent.new(worldwide_organisation:))

    assert_selector ".govuk-summary-list__row", count: 3
    assert_selector ".govuk-summary-list__row:nth-child(1) .govuk-summary-list__key", text: "Name"
    assert_selector ".govuk-summary-list__row:nth-child(1) .govuk-summary-list__value", text: worldwide_organisation.name
    assert_selector ".govuk-summary-list__row:nth-child(2) .govuk-summary-list__key", text: "World location 1"
    assert_selector ".govuk-summary-list__row:nth-child(2) .govuk-summary-list__value", text: world_location1.name
    assert_selector ".govuk-summary-list__row:nth-child(3) .govuk-summary-list__key", text: "World location 2"
    assert_selector ".govuk-summary-list__row:nth-child(3) .govuk-summary-list__value", text: world_location2.name
  end

  test "renders the correct items when the worldwide organisation has multiple sponsoring_organisations" do
    sponsoring_organisation1 = build_stubbed(:organisation)
    sponsoring_organisation2 = build_stubbed(:organisation)
    worldwide_organisation = build_stubbed(
      :worldwide_organisation,
      logo_formatted_name: nil,
      sponsoring_organisations: [sponsoring_organisation1, sponsoring_organisation2],
    )

    render_inline(Admin::WorldwideOrganisations::Show::SummaryListComponent.new(worldwide_organisation:))

    assert_selector ".govuk-summary-list__row", count: 3
    assert_selector ".govuk-summary-list__row:nth-child(1) .govuk-summary-list__key", text: "Name"
    assert_selector ".govuk-summary-list__row:nth-child(1) .govuk-summary-list__value", text: worldwide_organisation.name
    assert_selector ".govuk-summary-list__row:nth-child(2) .govuk-summary-list__key", text: "Sponsoring organisation 1"
    assert_selector ".govuk-summary-list__row:nth-child(2) .govuk-summary-list__value", text: sponsoring_organisation1.name
    assert_selector ".govuk-summary-list__row:nth-child(3) .govuk-summary-list__key", text: "Sponsoring organisation 2"
    assert_selector ".govuk-summary-list__row:nth-child(3) .govuk-summary-list__value", text: sponsoring_organisation2.name
  end
end
