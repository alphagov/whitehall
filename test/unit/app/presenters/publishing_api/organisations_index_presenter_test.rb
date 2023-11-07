require "test_helper"

class PublishingApi::OrganisationsPresenterTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  def setup
    organisation_one = create(:organisation, organisation_type_key: :executive_office)
    organisation_two = create(:organisation, organisation_type_key: :ministerial_department)
    organisation_three = create(:organisation, organisation_type_key: :non_ministerial_department)
    organisation_four = create(:organisation, organisation_type_key: :executive_agency)
    organisation_five = create(:sub_organisation, parent_organisations: [organisation_four])
    organisation_six = create(:organisation, organisation_type_key: :public_corporation)
    organisation_seven = create(:devolved_administration)

    @expected_hash = {
      title: "Departments, agencies and public bodies",
      locale: "en",
      publishing_app: Whitehall::PublishingApp::WHITEHALL,
      redirects: [],
      update_type: "minor",
      base_path: "/government/organisations",
      description: "Information from government departments, agencies and public bodies, including news, campaigns, policies and contact details.",
      document_type: "finder",
      public_updated_at: Time.zone.now.iso8601,
      rendering_app: Whitehall::RenderingApp::COLLECTIONS_FRONTEND,
      schema_name: "organisations_homepage",
      details: {
        ordered_executive_offices: [
          {
            title: organisation_one.name,
            href: "/government/organisations/#{organisation_one.name}",
            brand: nil,
            logo: {
              formatted_title: organisation_one.name,
              crest: "single-identity",
            },
            separate_website: false,
            format: "Executive office",
            updated_at: Time.zone.now,
            slug: organisation_one.slug,
            acronym: nil,
            closed_at: nil,
            govuk_status: "live",
            govuk_closed_status: nil,
            content_id: organisation_one.content_id,
            analytics_identifier: organisation_one.analytics_identifier,
            parent_organisations: [],
            child_organisations: [],
            superseded_organisations: [],
            superseding_organisations: [],
            works_with: {},
          },
        ],
        ordered_ministerial_departments: [
          {
            title: organisation_two.name,
            href: "/government/organisations/#{organisation_two.name}",
            brand: nil,
            logo: {
              formatted_title: organisation_two.name,
              crest: "single-identity",
            },
            separate_website: false,
            format: "Ministerial department",
            updated_at: Time.zone.now,
            slug: organisation_two.slug,
            acronym: nil,
            closed_at: nil,
            govuk_status: "live",
            govuk_closed_status: nil,
            content_id: organisation_two.content_id,
            analytics_identifier: organisation_two.analytics_identifier,
            parent_organisations: [],
            child_organisations: [],
            superseded_organisations: [],
            superseding_organisations: [],
            works_with: {},
          },
        ],
        ordered_non_ministerial_departments: [
          {
            title: organisation_three.name,
            href: "/government/organisations/#{organisation_three.name}",
            brand: nil,
            logo: {
              formatted_title: organisation_three.name,
              crest: "single-identity",
            },
            separate_website: false,
            format: "Non-ministerial department",
            updated_at: Time.zone.now,
            slug: organisation_three.slug,
            acronym: nil,
            closed_at: nil,
            govuk_status: "live",
            govuk_closed_status: nil,
            content_id: organisation_three.content_id,
            analytics_identifier: organisation_three.analytics_identifier,
            parent_organisations: [],
            child_organisations: [],
            superseded_organisations: [],
            superseding_organisations: [],
            works_with: {},
          },
        ],
        ordered_agencies_and_other_public_bodies: [
          {
            title: organisation_four.name,
            href: "/government/organisations/#{organisation_four.name}",
            brand: nil,
            logo: {
              formatted_title: organisation_four.name,
              crest: "single-identity",
            },
            separate_website: false,
            format: "Executive agency",
            updated_at: Time.zone.now,
            slug: organisation_four.slug,
            acronym: nil,
            closed_at: nil,
            govuk_status: "live",
            govuk_closed_status: nil,
            content_id: organisation_four.content_id,
            analytics_identifier: organisation_four.analytics_identifier,
            parent_organisations: [],
            child_organisations: [{ title: organisation_five.name, href: "/government/organisations/#{organisation_five.name}" }],
            superseded_organisations: [],
            superseding_organisations: [],
            works_with: {},
          },
        ],
        ordered_high_profile_groups: [
          {
            title: organisation_five.name,
            href: "/government/organisations/#{organisation_five.name}",
            brand: nil,
            logo: {
              formatted_title: organisation_five.name,
              crest: "single-identity",
            },
            separate_website: false,
            format: "Sub-organisation",
            updated_at: Time.zone.now,
            slug: organisation_five.slug,
            acronym: nil,
            closed_at: nil,
            govuk_status: "live",
            govuk_closed_status: nil,
            content_id: organisation_five.content_id,
            analytics_identifier: organisation_five.analytics_identifier,
            parent_organisations: [{ title: organisation_four.name, href: "/government/organisations/#{organisation_four.name}" }],
            child_organisations: [],
            superseded_organisations: [],
            superseding_organisations: [],
            works_with: {},
          },
        ],
        ordered_public_corporations: [
          {
            title: organisation_six.name,
            href: "/government/organisations/#{organisation_six.name}",
            brand: nil,
            logo: {
              formatted_title: organisation_six.name,
              crest: "single-identity",
            },
            separate_website: false,
            format: "Public corporation",
            updated_at: Time.zone.now,
            slug: organisation_six.slug,
            acronym: nil,
            closed_at: nil,
            govuk_status: "live",
            govuk_closed_status: nil,
            content_id: organisation_six.content_id,
            analytics_identifier: organisation_six.analytics_identifier,
            parent_organisations: [],
            child_organisations: [],
            superseded_organisations: [],
            superseding_organisations: [],
            works_with: {},
          },
        ],
        ordered_devolved_administrations: [
          {
            title: organisation_seven.name,
            href: "/government/organisations/#{organisation_seven.name}",
            brand: nil,
            logo: {
              formatted_title: organisation_seven.name,
              crest: "single-identity",
            },
            separate_website: true,
            format: "Devolved administration",
            updated_at: Time.zone.now,
            slug: organisation_seven.slug,
            acronym: nil,
            closed_at: nil,
            govuk_status: "exempt",
            govuk_closed_status: nil,
            content_id: organisation_seven.content_id,
            analytics_identifier: organisation_seven.analytics_identifier,
            parent_organisations: [],
            child_organisations: [],
            superseded_organisations: [],
            superseding_organisations: [],
            works_with: {},
          },
        ],
      },
      routes: [
        {
          path: "/government/organisations",
          type: "exact",
        },
      ],
    }
  end

  test "presents a valid content item" do
    presenter = PublishingApi::OrganisationsIndexPresenter.new
    assert_equal @expected_hash, presenter.content
    assert_valid_against_publisher_schema(presenter.content, "organisations_homepage")
  end

  test "presents content items in English, even when locale is Welsh" do
    I18n.with_locale(:cy) do
      presenter = PublishingApi::OrganisationsIndexPresenter.new
      assert_equal @expected_hash, presenter.content
      assert_valid_against_publisher_schema(presenter.content, "organisations_homepage")
    end
  end
end
