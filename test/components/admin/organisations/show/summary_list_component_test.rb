# frozen_string_literal: true

require "test_helper"

class Admin::Organisations::Show::SummaryListComponentTest < ViewComponent::TestCase
  include Rails.application.routes.url_helpers

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
    organisation = build_stubbed(:organisation, url: "http://parrot.org")

    expected_rows = [
      {
        key: "Type", value: "Other"
      },
      {
        key: "Acronym", value: nil
      },
      {
        key: "URL", value: "http://parrot.org", links: [{ href: "http://parrot.org", text: "http://parrot.org" }]
      },
      {
        key: "Status on GOV.UK", value: "Live"
      },
      {
        key: "Description To edit this, select the 'Corporate Information pages' tab. Click on 'About us' and edit the 'Summary' field in a new edition",
        value: nil,
      },
      {
        key: "Email address for ordering attached files in an alternative format", value: nil
      },
      {
        key: "Organisation chart URL", value: nil
      },
      {
        key: "Custom jobs URL", value: nil
      },
      {
        key: "Sponsoring organisations", value: "None"
      },
      {
        key: "Topical events", value: "None"
      },
      {
        key: "Crest", value: "Single Identity"
      },
      {
        key: "Brand colour", value: "None"
      },
      {
        key: "Analytics identifier", value: organisation.analytics_identifier
      },
      {
        key: "Featured links", value: "None"
      },
    ]

    render_inline(Admin::Organisations::Show::SummaryListComponent.new(organisation:))

    expected_rows.each do |row|
      assert has_row?(row)
    end
  end

  test "renders closed rows when org is closed" do
    superseding_organisation = build_stubbed(:ministerial_department)
    organisation = build_stubbed(:ministerial_department, :closed, url: "http://parrot.org", closed_at: Time.zone.now)
    organisation.stubs(:superseding_organisations).returns([superseding_organisation])

    expected_rows = [
      {
        key: "Organisation closed on",
        value: "11 November 2011",
      },
      {
        key: "Superseded by",
        value: superseding_organisation.name,
        links: [
          {
            href: "/government/admin/organisations/#{superseding_organisation.id}",
            text: superseding_organisation.name,
          },
        ],
      },
    ]

    render_inline(Admin::Organisations::Show::SummaryListComponent.new(organisation:))

    expected_rows.each do |row|
      assert has_row?(row)
    end
  end

  test "renders Sponsoring organisations orgs in teh supporting orgs row when parent orgs are present" do
    parent_organisation1 = build_stubbed(:ministerial_department)
    parent_organisation2 = build_stubbed(:ministerial_department)
    organisation = build_stubbed(:ministerial_department, url: "http://parrot.org")
    organisation.stubs(:parent_organisations).returns([parent_organisation1, parent_organisation2])

    expected_row = {
      key: "Sponsoring organisations",
      value: "#{parent_organisation1.name} and #{parent_organisation2.name}",
      links: [
        {
          href: "/government/admin/organisations/#{parent_organisation1.id}",
          text: parent_organisation1.name,
        },
        {
          href: "/government/admin/organisations/#{parent_organisation2.id}",
          text: parent_organisation2.name,
        },
      ],
    }

    render_inline(Admin::Organisations::Show::SummaryListComponent.new(organisation:))

    assert has_row?(expected_row)
  end

  test "renders Topical events in the topical events row if present" do
    organisation = build_stubbed(:ministerial_department, url: "http://parrot.org")
    topical_event1 = build_stubbed(:topical_event, organisations: [organisation])
    topical_event2 = build_stubbed(:topical_event, organisations: [organisation])
    organisation.stubs(:topical_events).returns([topical_event1, topical_event2])

    expected_row = {
      key: "Topical events",
      value: "#{topical_event1.name} and #{topical_event2.name}",
      links: [
        {
          href: "/government/admin/topical-events/#{topical_event1.id}",
          text: topical_event1.name,
        },
        {
          href: "/government/admin/topical-events/#{topical_event2.id}",
          text: topical_event2.name,
        },
      ],
    }

    render_inline(Admin::Organisations::Show::SummaryListComponent.new(organisation:))

    assert has_row?(expected_row)
  end

  test "renders each social media account in a separate row if present" do
    organisation = build_stubbed(:ministerial_department, url: "http://parrot.org")
    social_media_account1 = build_stubbed(:social_media_account)
    social_media_account2 = build_stubbed(:social_media_account)
    organisation.stubs(:social_media_accounts).returns([social_media_account1, social_media_account2])

    expected_rows = [
      {
        key: social_media_account1.social_media_service.name,
        value: social_media_account1.url,
        links: [
          {
            href: social_media_account1.url,
            text: social_media_account1.url,
          },
        ],
      },
      {
        key: social_media_account2.social_media_service.name,
        value: social_media_account2.url,
        links: [
          {
            href: social_media_account2.url,
            text: social_media_account2.url,
          },
        ],
      },
    ]

    render_inline(Admin::Organisations::Show::SummaryListComponent.new(organisation:))

    expected_rows.each do |row|
      assert has_row?(row)
    end
  end

  test "renders brand colour in brand colour row if present" do
    organisation = build_stubbed(:ministerial_department, url: "http://parrot.org", organisation_brand_colour_id: 2)

    expected_row = {
      key: "Brand colour",
      value: "Cabinet Office",
    }

    render_inline(Admin::Organisations::Show::SummaryListComponent.new(organisation:))

    assert has_row?(expected_row)
  end

  test "renders featured links in featured links row if present" do
    organisation = build_stubbed(:ministerial_department, url: "http://parrot.org")
    featured_link1 = build_stubbed(:featured_link)
    featured_link2 = build_stubbed(:featured_link, title: "An example service 2", url: "https://www.gov.uk/example/service2")
    organisation.stubs(:featured_links).returns([featured_link1, featured_link2])

    expected_row = {
      key: "Featured links",
      value: "  \n      An example service\n      An example service 2\n",
      links: [
        {
          href: featured_link1.url,
          text: featured_link1.title,
        },
        {
          href: featured_link2.url,
          text: featured_link2.title,
        },
      ],
    }

    render_inline(Admin::Organisations::Show::SummaryListComponent.new(organisation:))

    assert has_row?(expected_row)
  end

  def has_row?(row)
    assert_selector ".govuk-summary-list__row" do
      assert_selector ".govuk-summary-list__key", text: row[:key]
      assert_selector ".govuk-summary-list__value", text: row[:value]
    end
    assert_links(row)
  end

  def assert_links(row)
    return true if row[:links].blank?

    row[:links].all? do |link|
      assert_selector ".govuk-summary-list__value", text: row[:value] do
        assert_link(link[:text], href: link[:href])
      end
    end
  end
end
