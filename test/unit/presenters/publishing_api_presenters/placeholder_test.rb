require 'test_helper'

class PublishingApiPresenters::PlaceholderTest < ActiveSupport::TestCase
  def present(model_instance, options = {})
    PublishingApiPresenters::Placeholder.new(model_instance, options).as_json
  end

  test 'presents a Ministerial Role ready for adding to the publishing API' do
    ministerial_role = create(:ministerial_role, name: "Secretary of State for Silly Walks")
    public_path = Whitehall.url_maker.ministerial_role_path(ministerial_role)

    expected_hash = {
      content_id: ministerial_role.content_id,
      title: "Secretary of State for Silly Walks",
      format: "placeholder_ministerial_role",
      locale: 'en',
      publishing_app: 'whitehall',
      rendering_app: 'whitehall-frontend',
      public_updated_at: ministerial_role.updated_at,
      routes: [ { path: public_path, type: "exact" } ],
      update_type: "major",
    }

    presented_hash = present(ministerial_role)
    assert_equal expected_hash, presented_hash
    assert_valid_against_schema(presented_hash, 'placeholder')
  end

  test 'presents an Organisation ready for adding to the publishing API' do
    organisation = create(:organisation, name: 'Organisation of Things', analytics_identifier: 'O123')
    public_path = Whitehall.url_maker.organisation_path(organisation)

    expected_hash = {
      content_id: organisation.content_id,
      title: "Organisation of Things",
      format: "placeholder_organisation",
      locale: 'en',
      publishing_app: 'whitehall',
      rendering_app: 'whitehall-frontend',
      public_updated_at: organisation.updated_at,
      routes: [ { path: public_path, type: "exact" } ],
      update_type: "major",
      analytics_identifier: "O123",
    }

    presented_hash = present(organisation)
    assert_equal expected_hash, presented_hash
    assert_valid_against_schema(presented_hash, 'placeholder')
  end

  test 'presents a Person ready for adding to the publishing API' do
    person = create(:person, forename: "Winston")
    public_path = Whitehall.url_maker.person_path(person)

    expected_hash = {
      content_id: person.content_id,
      title: "Winston",
      format: "placeholder_person",
      locale: 'en',
      publishing_app: 'whitehall',
      rendering_app: 'whitehall-frontend',
      public_updated_at: person.updated_at,
      routes: [ { path: public_path, type: "exact" } ],
      update_type: "major",
    }

    presented_hash = present(person)
    assert_equal expected_hash, presented_hash
    assert_valid_against_schema(presented_hash, 'placeholder')
  end

  test 'presents a Worldwide Organisation ready for adding to the publishing API' do
    worldwide_org = create(:worldwide_organisation, name: 'Locationia Embassy', analytics_identifier: 'WO123')
    public_path = Whitehall.url_maker.worldwide_organisation_path(worldwide_org)

    expected_hash = {
      content_id: worldwide_org.content_id,
      title: "Locationia Embassy",
      format: "placeholder_worldwide_organisation",
      locale: 'en',
      publishing_app: 'whitehall',
      rendering_app: 'whitehall-frontend',
      public_updated_at: worldwide_org.updated_at,
      routes: [ { path: public_path, type: "exact" } ],
      update_type: "major",
      analytics_identifier: "WO123",
    }

    presented_hash = present(worldwide_org)
    assert_equal expected_hash, presented_hash
    assert_valid_against_schema(presented_hash, 'placeholder')
  end

  test 'presents a World Location ready for adding to the publishing API' do
    world_location = create(:world_location, name: 'Locationia', analytics_identifier: 'WL123')
    public_path = Whitehall.url_maker.world_location_path(world_location)

    expected_hash = {
      content_id: world_location.content_id,
      title: "Locationia",
      format: "placeholder_world_location",
      locale: 'en',
      publishing_app: 'whitehall',
      rendering_app: 'whitehall-frontend',
      public_updated_at: world_location.updated_at,
      routes: [ { path: public_path, type: "exact" } ],
      update_type: "major",
      analytics_identifier: "WL123",
    }

    presented_hash = present(world_location)
    assert_equal expected_hash, presented_hash
    assert_valid_against_schema(presented_hash, 'placeholder')
  end

  test 'update type can be overridden by passing an update_type option' do
    update_type_override = 'republish'
    organisation = create(:organisation)
    presented_hash = present(organisation, update_type: update_type_override)
    assert_equal update_type_override, presented_hash[:update_type]
  end

  test 'is locale aware' do
    organisation = create(:organisation)

    I18n.with_locale :fr do
      organisation.name = "French name"
      organisation.save!
      presented_hash = present(organisation)

      assert_equal 'fr', presented_hash[:locale]
      assert_equal 'French name', presented_hash[:title]
      assert_equal Whitehall.url_maker.organisation_path(organisation, locale: :fr),
        presented_hash[:routes].first[:path]

    end
  end
end
