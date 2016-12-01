require 'test_helper'

class RoutingLocaleTest < ActionDispatch::IntegrationTest
  test "#index in default locale" do
    assert_equal '/government/ministers', ministerial_roles_path
  end

  test "#index with english locale doesn't include locale in the path" do
    assert_equal '/government/ministers', ministerial_roles_path(locale: 'en')
  end

  test "#index with a non-english locale includes the locale in the path" do
    assert_equal '/government/ministers.fr', ministerial_roles_path(locale: 'fr')
  end

  test "#index with a format includes it in the path" do
    assert_equal '/government/ministers.atom', ministerial_roles_path(format: 'atom')
  end

  test "#index with a english locale and a format includes the format in the path" do
    assert_equal '/government/ministers.atom', ministerial_roles_path(locale: 'en', format: 'atom')
  end

  test "#index with a non-english locale and a format includes the locale and format in the path" do
    assert_equal '/government/ministers.dk.atom', ministerial_roles_path(locale: 'dk', format: 'atom')
  end

  test "#show with no locale" do
    ministerial_role = create(:ministerial_role)
    assert_equal "/government/ministers/#{ministerial_role.slug}",
      ministerial_role_path(ministerial_role)
  end

  test "#show with english locale doesn't includes the locale in the path" do
    ministerial_role = create(:ministerial_role)
    assert_equal "/government/ministers/#{ministerial_role.slug}",
      ministerial_role_path(ministerial_role, locale: 'en')
  end

  test "#show with non-english locale includes the locale in the path" do
    ministerial_role = create(:ministerial_role)
    assert_equal "/government/ministers/#{ministerial_role.slug}.dr",
      ministerial_role_path(ministerial_role, locale: 'dr')
  end

  test "#show with a format includes it in the path" do
    ministerial_role = create(:ministerial_role)
    assert_equal "/government/ministers/#{ministerial_role.slug}.json",
      ministerial_role_path(ministerial_role, format: 'json')
  end

  test "#show with a english locale and a format includes the format in the path" do
    ministerial_role = create(:ministerial_role)
    assert_equal "/government/ministers/#{ministerial_role.slug}.json",
      ministerial_role_path(ministerial_role, locale: 'en', format: 'json')
  end

  test "#show with a non-english locale and a format includes the locale and format in the path" do
    ministerial_role = create(:ministerial_role)
    assert_equal "/government/ministers/#{ministerial_role.slug}.cy.json",
      ministerial_role_path(ministerial_role, locale: 'cy', format: 'json')
  end

  test "#index for a non-localised resource with a format" do
    assert_equal "/government/publications.json", publications_path(format: 'json')
  end

  test "#show for a non-localised resource" do
    topic = create(:topic)
    assert_equal "/government/topics/#{topic.slug}", topic_path(topic)
  end

  test "#show for a non-localised resource with a format" do
    topic = create(:topic)
    assert_equal "/government/topics/#{topic.slug}.json", topic_path(topic, format: 'json')
  end
end
