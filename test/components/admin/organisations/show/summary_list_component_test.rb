# frozen_string_literal: true

require "test_helper"

class Admin::Organisations::Show::SummaryListComponentTest < ViewComponent::TestCase
  include Rails.application.routes.url_helpers
  include ApplicationHelper

  test "renders edit link when editable is true" do
    organisation = build_stubbed(:organisation, url: "http://parrot.org")
    render_inline(Admin::Organisations::Show::SummaryListComponent.new(organisation:, editable: true))

    assert_link("Edit", href: edit_admin_organisation_path(organisation))
  end

  test "does not render edit link when editable is false" do
    organisation = build_stubbed(:organisation, url: "http://parrot.org")
    render_inline(Admin::Organisations::Show::SummaryListComponent.new(organisation:))

    assert_no_link("Edit", href: edit_admin_organisation_path(organisation))
  end

  test "renders the default rows" do
    organisation = build_stubbed(:organisation)

    render_inline(Admin::Organisations::Show::SummaryListComponent.new(organisation:))

    assert_selector ".govuk-summary-list__row", count: 8
    assert_selector ".govuk-summary-list__row:nth-child(1) .govuk-summary-list__key", text: "Name"
    assert_selector ".govuk-summary-list__row:nth-child(1) .govuk-summary-list__value", text: organisation.name
    assert_selector ".govuk-summary-list__row:nth-child(2) .govuk-summary-list__key", text: "Logo formatted name"
    assert_selector ".govuk-summary-list__row:nth-child(2) .govuk-summary-list__value", text: organisation.logo_formatted_name
    assert_selector ".govuk-summary-list__row:nth-child(3) .govuk-summary-list__key", text: "Logo crest"
    assert_selector ".govuk-summary-list__row:nth-child(3) .govuk-summary-list__value", text: organisation.organisation_logo_type.title
    assert_selector ".govuk-summary-list__row:nth-child(4) .govuk-summary-list__key", text: "Type"
    assert_selector ".govuk-summary-list__row:nth-child(4) .govuk-summary-list__value", text: organisation.type.name
    assert_selector ".govuk-summary-list__row:nth-child(5) .govuk-summary-list__key", text: "Status on GOV.UK"
    assert_selector ".govuk-summary-list__row:nth-child(5) .govuk-summary-list__value", text: organisation.govuk_status.titleize
    assert_selector ".govuk-summary-list__row:nth-child(6) .govuk-summary-list__key", text: "Featured link position"
    assert_selector ".govuk-summary-list__row:nth-child(6) .govuk-summary-list__value", text: "News priority"
    assert_selector ".govuk-summary-list__row:nth-child(7) .govuk-summary-list__key", text: "Management team images on homepage"
    assert_selector ".govuk-summary-list__row:nth-child(7) .govuk-summary-list__value", text: organisation.important_board_members
    assert_selector ".govuk-summary-list__row:nth-child(8) .govuk-summary-list__key", text: "Analytics identifier"
    assert_selector ".govuk-summary-list__row:nth-child(8) .govuk-summary-list__value", text: organisation.analytics_identifier
  end

  test "renders acronym_row if the organisation has an acronym" do
    organisation = build_stubbed(:ministerial_department, acronym: "ACRO")

    render_inline(Admin::Organisations::Show::SummaryListComponent.new(organisation:))

    assert_selector ".govuk-summary-list__row", count: 9
    assert_selector ".govuk-summary-list__row:nth-child(2) .govuk-summary-list__key", text: "Acronym"
    assert_selector ".govuk-summary-list__row:nth-child(2) .govuk-summary-list__value", text: organisation.acronym
  end

  test "renders brand colour in brand colour row if present" do
    organisation = build_stubbed(:ministerial_department, organisation_brand_colour_id: 2)

    render_inline(Admin::Organisations::Show::SummaryListComponent.new(organisation:))

    assert_selector ".govuk-summary-list__row", count: 9
    assert_selector ".govuk-summary-list__row:nth-child(4) .govuk-summary-list__key", text: "Brand colour"
    assert_selector ".govuk-summary-list__row:nth-child(4) .govuk-summary-list__value", text: organisation.organisation_brand_colour.title
  end

  test "renders default news image row if the organisation has a default news image" do
    news_image = build_stubbed(:default_news_organisation_image_data)
    organisation = build_stubbed(:ministerial_department, default_news_image: news_image)

    render_inline(Admin::Organisations::Show::SummaryListComponent.new(organisation:))

    assert_selector ".govuk-summary-list__row", count: 9
    assert_selector ".govuk-summary-list__row:nth-child(4) .govuk-summary-list__key", text: "Default news image"
    assert_selector ".govuk-summary-list__row:nth-child(4) .govuk-summary-list__value img[src='#{news_image.file.url(:s300)}']"
  end

  test "renders url_row if the organisation has a url" do
    organisation = build_stubbed(:ministerial_department, url: "http://parrot.org")

    render_inline(Admin::Organisations::Show::SummaryListComponent.new(organisation:))

    assert_selector ".govuk-summary-list__row", count: 9
    assert_selector ".govuk-summary-list__row:nth-child(4) .govuk-summary-list__key", text: "Organisation’s URL"
    assert_selector ".govuk-summary-list__row:nth-child(4) .govuk-summary-list__value", text: "http://parrot.org"
    assert_selector ".govuk-summary-list__row:nth-child(4) .govuk-summary-list__actions a[href='#{organisation.url}']", text: /View/
  end

  test "renders alternative_format_contact_email_row if the organisation has an alternative_format_contact_email" do
    organisation = build_stubbed(:ministerial_department, alternative_format_contact_email: "test@email.com")

    render_inline(Admin::Organisations::Show::SummaryListComponent.new(organisation:))

    assert_selector ".govuk-summary-list__row", count: 9
    assert_selector ".govuk-summary-list__row:nth-child(5) .govuk-summary-list__key", text: "Accessible formats request email"
    assert_selector ".govuk-summary-list__row:nth-child(5) .govuk-summary-list__value", text: organisation.alternative_format_contact_email
  end

  test "renders correct closed rows when org is closed and there is 1 superseding organisation" do
    superseding_organisation = build_stubbed(:ministerial_department)
    organisation = build_stubbed(:ministerial_department, :closed, closed_at: Time.zone.now)
    organisation.stubs(:superseding_organisations).returns([superseding_organisation])

    render_inline(Admin::Organisations::Show::SummaryListComponent.new(organisation:))

    assert_selector ".govuk-summary-list__row", count: 11
    assert_selector ".govuk-summary-list__row:nth-child(6) .govuk-summary-list__key", text: "Reason for closure"
    assert_selector ".govuk-summary-list__row:nth-child(6) .govuk-summary-list__value", text: organisation.govuk_closed_status
    assert_selector ".govuk-summary-list__row:nth-child(7) .govuk-summary-list__key", text: "Organisation closed on"
    assert_selector ".govuk-summary-list__row:nth-child(7) .govuk-summary-list__value", text: "11 November 2011"
    assert_selector ".govuk-summary-list__row:nth-child(8) .govuk-summary-list__key", text: "Superseding organisation"
    assert_selector ".govuk-summary-list__row:nth-child(8) .govuk-summary-list__value", text: superseding_organisation.name
    assert_selector ".govuk-summary-list__row:nth-child(8) .govuk-summary-list__actions a[href='#{superseding_organisation.public_url}']", text: /View/
  end

  test "renders correct rows when closed and there are 2 superseding organisation" do
    superseding_organisation1 = build_stubbed(:ministerial_department)
    superseding_organisation2 = build_stubbed(:ministerial_department)
    organisation = build_stubbed(:ministerial_department, :closed, closed_at: Time.zone.now)
    organisation.stubs(:superseding_organisations).returns([superseding_organisation1, superseding_organisation2])

    render_inline(Admin::Organisations::Show::SummaryListComponent.new(organisation:))

    assert_selector ".govuk-summary-list__row", count: 12
    assert_selector ".govuk-summary-list__row:nth-child(8) .govuk-summary-list__key", text: "Superseding organisation 1"
    assert_selector ".govuk-summary-list__row:nth-child(8) .govuk-summary-list__value", text: superseding_organisation1.name
    assert_selector ".govuk-summary-list__row:nth-child(8) .govuk-summary-list__actions a[href='#{superseding_organisation1.public_url}']", text: /View/
    assert_selector ".govuk-summary-list__row:nth-child(9) .govuk-summary-list__key", text: "Superseding organisation 2"
    assert_selector ".govuk-summary-list__row:nth-child(9) .govuk-summary-list__value", text: superseding_organisation2.name
    assert_selector ".govuk-summary-list__row:nth-child(9) .govuk-summary-list__actions a[href='#{superseding_organisation2.public_url}']", text: /View/
  end

  test "renders organisation_chart_url_row if the organisation has an organisation_chart_url" do
    organisation = build_stubbed(:ministerial_department, organisation_chart_url: "organisation@chart.com")

    render_inline(Admin::Organisations::Show::SummaryListComponent.new(organisation:))

    assert_selector ".govuk-summary-list__row", count: 9
    assert_selector ".govuk-summary-list__row:nth-child(6) .govuk-summary-list__key", text: "Organisation chart URL"
    assert_selector ".govuk-summary-list__row:nth-child(6) .govuk-summary-list__value", text: organisation.organisation_chart_url
  end

  test "renders recruitment_url_row if the organisation has an recruitment_url" do
    organisation = build_stubbed(:ministerial_department, custom_jobs_url: "custom@jobs.com")

    render_inline(Admin::Organisations::Show::SummaryListComponent.new(organisation:))

    assert_selector ".govuk-summary-list__row", count: 9
    assert_selector ".govuk-summary-list__row:nth-child(6) .govuk-summary-list__key", text: "Recruitment URL"
    assert_selector ".govuk-summary-list__row:nth-child(6) .govuk-summary-list__value", text: organisation.custom_jobs_url
    assert_selector ".govuk-summary-list__row:nth-child(6) .govuk-summary-list__actions a[href='#{organisation.custom_jobs_url}']", text: /View/
  end

  test "renders political_row if the organisation has been marked as political" do
    organisation = build_stubbed(:ministerial_department, political: true)

    render_inline(Admin::Organisations::Show::SummaryListComponent.new(organisation:))

    assert_selector ".govuk-summary-list__row", count: 9
    assert_selector ".govuk-summary-list__row:nth-child(6) .govuk-summary-list__key", text: "Publishes content associated with the current government"
    assert_selector ".govuk-summary-list__row:nth-child(6) .govuk-summary-list__value", text: "Yes"
  end

  test "renders Sponsoring organisations row correctly when one parent org is present" do
    parent_organisation = build_stubbed(:ministerial_department)
    organisation = build_stubbed(:ministerial_department)
    organisation.stubs(:parent_organisations).returns([parent_organisation])

    render_inline(Admin::Organisations::Show::SummaryListComponent.new(organisation:))

    assert_selector ".govuk-summary-list__row", count: 9
    assert_selector ".govuk-summary-list__row:nth-child(6) .govuk-summary-list__key", text: "Sponsoring organisation"
    assert_selector ".govuk-summary-list__row:nth-child(6) .govuk-summary-list__value", text: parent_organisation.name
    assert_selector ".govuk-summary-list__row:nth-child(6) .govuk-summary-list__actions a[href='#{parent_organisation.public_url}']", text: /View/
  end

  test "renders Sponsoring organisations rows correctly when multiple parent orgs are present" do
    parent_organisation1 = build_stubbed(:ministerial_department)
    parent_organisation2 = build_stubbed(:ministerial_department)
    organisation = build_stubbed(:ministerial_department)
    organisation.stubs(:parent_organisations).returns([parent_organisation1, parent_organisation2])

    render_inline(Admin::Organisations::Show::SummaryListComponent.new(organisation:))

    assert_selector ".govuk-summary-list__row", count: 10
    assert_selector ".govuk-summary-list__row:nth-child(6) .govuk-summary-list__key", text: "Sponsoring organisation 1"
    assert_selector ".govuk-summary-list__row:nth-child(6) .govuk-summary-list__value", text: parent_organisation1.name
    assert_selector ".govuk-summary-list__row:nth-child(6) .govuk-summary-list__actions a[href='#{parent_organisation1.public_url}']", text: /View/
    assert_selector ".govuk-summary-list__row:nth-child(7) .govuk-summary-list__key", text: "Sponsoring organisation 2"
    assert_selector ".govuk-summary-list__row:nth-child(7) .govuk-summary-list__value", text: parent_organisation2.name
    assert_selector ".govuk-summary-list__row:nth-child(7) .govuk-summary-list__actions a[href='#{parent_organisation2.public_url}']", text: /View/
  end

  test "renders topical_events_row correctly when one parent org is present" do
    topical_event = build_stubbed(:topical_event)
    organisation = build_stubbed(:ministerial_department)
    organisation.stubs(:topical_events).returns([topical_event])

    render_inline(Admin::Organisations::Show::SummaryListComponent.new(organisation:))

    assert_selector ".govuk-summary-list__row", count: 9
    assert_selector ".govuk-summary-list__row:nth-child(6) .govuk-summary-list__key", text: "Topical event"
    assert_selector ".govuk-summary-list__row:nth-child(6) .govuk-summary-list__value", text: topical_event.name
    assert_selector ".govuk-summary-list__row:nth-child(6) .govuk-summary-list__actions a[href='#{topical_event.public_url}']", text: /View/
  end

  test "renders topical_events_rows correctly when multiple topical events are present" do
    topical_event1 = build_stubbed(:topical_event)
    topical_event2 = build_stubbed(:topical_event)
    organisation = build_stubbed(:ministerial_department)
    organisation.stubs(:topical_events).returns([topical_event1, topical_event2])

    render_inline(Admin::Organisations::Show::SummaryListComponent.new(organisation:))

    assert_selector ".govuk-summary-list__row", count: 10
    assert_selector ".govuk-summary-list__row:nth-child(6) .govuk-summary-list__key", text: "Topical event 1"
    assert_selector ".govuk-summary-list__row:nth-child(6) .govuk-summary-list__value", text: topical_event1.name
    assert_selector ".govuk-summary-list__row:nth-child(6) .govuk-summary-list__actions a[href='#{topical_event1.public_url}']", text: /View/
    assert_selector ".govuk-summary-list__row:nth-child(7) .govuk-summary-list__key", text: "Topical event 2"
    assert_selector ".govuk-summary-list__row:nth-child(7) .govuk-summary-list__value", text: topical_event2.name
    assert_selector ".govuk-summary-list__row:nth-child(7) .govuk-summary-list__actions a[href='#{topical_event2.public_url}']", text: /View/
  end

  test "renders featured_link correctly when one featured link is present" do
    featured_link = build_stubbed(:featured_link)
    organisation = build_stubbed(:ministerial_department)
    organisation.stubs(:featured_links).returns([featured_link])

    render_inline(Admin::Organisations::Show::SummaryListComponent.new(organisation:))

    assert_selector ".govuk-summary-list__row", count: 9
    assert_selector ".govuk-summary-list__row:nth-child(7) .govuk-summary-list__key", text: "Featured link"
    assert_selector ".govuk-summary-list__row:nth-child(7) .govuk-summary-list__value", text: featured_link.title
    assert_selector ".govuk-summary-list__row:nth-child(7) .govuk-summary-list__actions a[href='#{featured_link.url}']", text: /View/
  end

  test "renders featured_links correctly when multiple featured links are present" do
    featured_link1 = build_stubbed(:featured_link)
    featured_link2 = build_stubbed(:featured_link)
    organisation = build_stubbed(:ministerial_department)
    organisation.stubs(:featured_links).returns([featured_link1, featured_link2])

    render_inline(Admin::Organisations::Show::SummaryListComponent.new(organisation:))

    assert_selector ".govuk-summary-list__row", count: 10
    assert_selector ".govuk-summary-list__row:nth-child(7) .govuk-summary-list__key", text: "Featured link 1"
    assert_selector ".govuk-summary-list__row:nth-child(7) .govuk-summary-list__value", text: featured_link1.title
    assert_selector ".govuk-summary-list__row:nth-child(7) .govuk-summary-list__actions a[href='#{featured_link1.url}']", text: /View/
    assert_selector ".govuk-summary-list__row:nth-child(8) .govuk-summary-list__key", text: "Featured link 2"
    assert_selector ".govuk-summary-list__row:nth-child(8) .govuk-summary-list__value", text: featured_link2.title
    assert_selector ".govuk-summary-list__row:nth-child(8) .govuk-summary-list__actions a[href='#{featured_link2.url}']", text: /View/
  end

  test "renders foi_exempt_row if the organisation is exempt from FOI requests" do
    organisation = build_stubbed(:ministerial_department, foi_exempt: true)

    render_inline(Admin::Organisations::Show::SummaryListComponent.new(organisation:))

    assert_selector ".govuk-summary-list__row", count: 9
    assert_selector ".govuk-summary-list__row:nth-child(8) .govuk-summary-list__key", text: "Exempt from Freedom of Information requests"
    assert_selector ".govuk-summary-list__row:nth-child(8) .govuk-summary-list__value", text: "Yes"
  end
end
