require "test_helper"

class RoutingLocaleTest < ActionDispatch::IntegrationTest
  include PublicDocumentRoutesHelper

  test "#index in default locale" do
    assert_equal "/government/ministers", ministerial_roles_path
  end

  test "#index with english locale doesn't include locale in the path" do
    assert_equal "/government/ministers", ministerial_roles_path(locale: "en")
  end

  test "#index with a non-english locale includes the locale in the path" do
    assert_equal "/government/ministers.fr", ministerial_roles_path(locale: "fr")
  end

  test "#index with a format includes it in the path" do
    assert_equal "/government/ministers.atom", ministerial_roles_path(format: "atom")
  end

  test "#index with a english locale and a format includes the format in the path" do
    assert_equal "/government/ministers.atom", ministerial_roles_path(locale: "en", format: "atom")
  end

  test "#index with a non-english locale and a format includes the locale and format in the path" do
    assert_equal "/government/ministers.dk.atom", ministerial_roles_path(locale: "dk", format: "atom")
  end

  test "#index with a non-english I18n.locale" do
    I18n.with_locale(:fr) do
      assert_equal "/government/ministers.fr", ministerial_roles_path
    end
  end

  test "#index with a non-english I18n.locale and an overridden locale" do
    I18n.with_locale(:fr) do
      assert_equal "/government/ministers.de", ministerial_roles_path(locale: "de")
      assert_equal "/government/ministers", ministerial_roles_path(locale: "en")
      assert_equal "/government/ministers", ministerial_roles_path(locale: "")
    end
  end

  test "#show with no locale" do
    worldwide_organisation = create(:worldwide_organisation)
    assert_equal "/world/organisations/#{worldwide_organisation.slug}",
                 worldwide_organisation_path(worldwide_organisation)
  end

  test "#show with english locale doesn't includes the locale in the path" do
    worldwide_organisation = create(:worldwide_organisation)
    assert_equal "/world/organisations/#{worldwide_organisation.slug}",
                 worldwide_organisation_path(worldwide_organisation, locale: "en")
  end

  test "#show with non-english locale includes the locale in the path" do
    worldwide_organisation = I18n.with_locale(:dr) { create(:worldwide_organisation) }
    assert_equal "/world/organisations/#{worldwide_organisation.slug}.dr",
                 worldwide_organisation_path(worldwide_organisation, locale: "dr")
  end

  test "#show with a format includes it in the path" do
    worldwide_organisation = create(:worldwide_organisation)
    assert_equal "/world/organisations/#{worldwide_organisation.slug}.json",
                 worldwide_organisation_path(worldwide_organisation, format: "json")
  end

  test "#show with a english locale and a format includes the format in the path" do
    worldwide_organisation = create(:worldwide_organisation)
    assert_equal "/world/organisations/#{worldwide_organisation.slug}.json",
                 worldwide_organisation_path(worldwide_organisation, locale: "en", format: "json")
  end

  test "#show with a non-english locale and a format includes the locale and format in the path" do
    worldwide_organisation = I18n.with_locale(:cy) { create(:worldwide_organisation) }
    assert_equal "/world/organisations/#{worldwide_organisation.slug}.cy.json",
                 worldwide_organisation_path(worldwide_organisation, locale: "cy", format: "json")
  end

  test "#index for a non-localised resource with a format" do
    assert_equal "/government/publications.json", publications_path(format: "json")
  end

  test "#show for a non-localised resource" do
    topical_event = create(:topical_event)
    assert_equal "/government/topical-events/#{topical_event.slug}", topical_event_path(topical_event)
  end

  test "#show for a non-localised resource with a format" do
    topical_event = create(:topical_event)
    assert_equal "/government/topical-events/#{topical_event.slug}.json", topical_event_path(topical_event, format: "json")
  end
end
