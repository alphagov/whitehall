require 'test_helper'

class PublishingApiPresenters::PlaceholderTest < ActiveSupport::TestCase
  def present(model_instance, options = {})
    PublishingApiPresenters::Placeholder.new(model_instance, options)
  end

  test 'presents a Ministerial Role ready for adding to the publishing API' do
    ministerial_role = create(:ministerial_role, name: "Secretary of State for Silly Walks")
    public_path = Whitehall.url_maker.ministerial_role_path(ministerial_role)

    expected_hash = {
      base_path: public_path,
      title: "Secretary of State for Silly Walks",
      description: nil,
      format: "placeholder_ministerial_role",
      locale: 'en',
      publishing_app: 'whitehall',
      rendering_app: 'whitehall-frontend',
      public_updated_at: ministerial_role.updated_at,
      routes: [{ path: public_path, type: "exact" }],
      redirects: [],
      need_ids: [],
      details: {},
    }
    expected_links = { topics: [] }

    presented_item = present(ministerial_role)

    assert_equal expected_hash, presented_item.content
    assert_equal expected_links, presented_item.links
    assert_equal "major", presented_item.update_type
    assert_equal ministerial_role.content_id, presented_item.content_id

    assert_valid_against_schema(presented_item.content, 'placeholder')
  end

  test 'presents a Person ready for adding to the publishing API' do
    person = create(:person, forename: "Winston")
    public_path = Whitehall.url_maker.person_path(person)

    expected_hash = {
      base_path: public_path,
      title: "Winston",
      description: nil,
      format: "placeholder_person",
      locale: 'en',
      publishing_app: 'whitehall',
      rendering_app: 'whitehall-frontend',
      public_updated_at: person.updated_at,
      routes: [{ path: public_path, type: "exact" }],
      redirects: [],
      need_ids: [],
      details: {},
    }
    expected_links = { topics: [] }

    presented_item = present(person)

    assert_equal expected_hash, presented_item.content
    assert_equal expected_links, presented_item.links
    assert_equal "major", presented_item.update_type
    assert_equal person.content_id, presented_item.content_id

    assert_valid_against_schema(presented_item.content, 'placeholder')
  end

  test 'presents a Worldwide Organisation ready for adding to the publishing API' do
    worldwide_org = create(:worldwide_organisation, name: 'Locationia Embassy', analytics_identifier: 'WO123')
    public_path = Whitehall.url_maker.worldwide_organisation_path(worldwide_org)

    expected_hash = {
      base_path: public_path,
      title: "Locationia Embassy",
      description: nil,
      format: "placeholder_worldwide_organisation",
      locale: 'en',
      publishing_app: 'whitehall',
      rendering_app: 'whitehall-frontend',
      public_updated_at: worldwide_org.updated_at,
      routes: [{ path: public_path, type: "exact" }],
      redirects: [],
      need_ids: [],
      details: {},
      analytics_identifier: "WO123",
    }
    expected_links = { topics: [] }

    presented_item = present(worldwide_org)

    assert_equal expected_hash, presented_item.content
    assert_equal expected_links, presented_item.links
    assert_equal "major", presented_item.update_type
    assert_equal worldwide_org.content_id, presented_item.content_id

    assert_valid_against_schema(presented_item.content, 'placeholder')
  end

  test 'presents a World Location ready for adding to the publishing API' do
    world_location = create(:world_location, name: 'Locationia', analytics_identifier: 'WL123')
    public_path = Whitehall.url_maker.world_location_path(world_location)

    expected_hash = {
      base_path: public_path,
      title: "Locationia",
      description: nil,
      format: "placeholder_world_location",
      locale: 'en',
      publishing_app: 'whitehall',
      rendering_app: 'whitehall-frontend',
      public_updated_at: world_location.updated_at,
      routes: [{ path: public_path, type: "exact" }],
      redirects: [],
      need_ids: [],
      details: {},
      analytics_identifier: "WL123",
    }
    expected_links = { topics: [] }

    presented_item = present(world_location)

    assert_equal expected_hash, presented_item.content
    assert_equal expected_links, presented_item.links
    assert_equal "major", presented_item.update_type
    assert_equal world_location.content_id, presented_item.content_id

    assert_valid_against_schema(presented_item.content, 'placeholder')
  end

  test 'update type can be overridden by passing an update_type option' do
    update_type_override = 'republish'
    organisation = create(:organisation)
    presented_item = present(organisation, update_type: update_type_override)
    assert_equal update_type_override, presented_item.update_type
  end

  test 'is locale aware' do
    organisation = create(:organisation)

    I18n.with_locale :fr do
      organisation.name = "French name"
      organisation.save!
      presented_item = present(organisation)

      assert_equal 'fr', presented_item.content[:locale]
      assert_equal 'French name', presented_item.content[:title]
      assert_equal Whitehall.url_maker.organisation_path(organisation, locale: :fr),
        presented_item.content[:routes].first[:path]
    end
  end
end
