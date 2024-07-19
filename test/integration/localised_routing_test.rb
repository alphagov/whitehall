require "test_helper"

class RoutingLocaleTest < ActionDispatch::IntegrationTest
  test "#show with no locale" do
    worldwide_organisation = create(:worldwide_organisation)
    assert_equal "/world/organisations/#{worldwide_organisation.slug}",
                 worldwide_organisation.public_path
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

  test "#show with a format includes it in the path" do
    worldwide_organisation = create(:worldwide_organisation)
    assert_equal "/world/organisations/#{worldwide_organisation.slug}.json",
                 worldwide_organisation.public_path(format: "json")
  end

  test "#show with a english locale and a format includes the format in the path" do
    worldwide_organisation = create(:worldwide_organisation)
    assert_equal "/world/organisations/#{worldwide_organisation.slug}.json",
                 worldwide_organisation.public_path(locale: "en", format: "json")
  end

  test "#show with a non-english locale and a format includes the locale and format in the path" do
    worldwide_organisation = I18n.with_locale(:cy) { create(:worldwide_organisation) }
    assert_equal "/world/organisations/#{worldwide_organisation.slug}.cy.json",
                 worldwide_organisation.public_path(locale: "cy", format: "json")
  end
end
