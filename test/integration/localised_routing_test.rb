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

  test "#show with english locale doesn't includes the locale in the path" do
    worldwide_organisation = create(:worldwide_organisation)
    assert_equal "/world/organisations/#{worldwide_organisation.slug}",
                 worldwide_organisation.public_path(locale: "en")
  end

  test "#show with non-english locale includes the locale in the path" do
    worldwide_organisation = I18n.with_locale(:dr) { create(:worldwide_organisation) }
    assert_equal "/world/organisations/#{worldwide_organisation.slug}.dr",
                 worldwide_organisation.public_path(locale: "dr")
  end

  test "#show with a english locale and a format includes the format in the path" do
    worldwide_organisation = create(:worldwide_organisation)
    assert_equal "/world/organisations/#{worldwide_organisation.slug}.json",
                 worldwide_organisation.public_path({ format: "json" }, locale: "en")
  end

  test "#show with a non-english locale and a format includes the locale and format in the path" do
    worldwide_organisation = I18n.with_locale(:cy) { create(:worldwide_organisation) }
    assert_equal "/world/organisations/#{worldwide_organisation.slug}.cy.json",
                 worldwide_organisation.public_path({ format: "json" }, locale: "cy")
  end
end
