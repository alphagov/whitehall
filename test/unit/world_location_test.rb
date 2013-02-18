require 'test_helper'

class WorldLocationTest < ActiveSupport::TestCase
  should_protect_against_xss_and_content_attacks_on :name, :mission_statement

  test 'should be invalid without a name' do
    world_location = build(:world_location, name: nil)
    refute world_location.valid?
  end

  test "should be invalid without a world location type" do
    world_location = build(:world_location, world_location_type: nil)
    refute world_location.valid?
  end

  test 'should set a slug from the name' do
    world_location = create(:world_location, name: 'Costa Rica')
    assert_equal 'costa-rica', world_location.slug
  end

  test 'should not change the slug when the name is changed' do
    world_location = create(:world_location, name: 'New Holland')
    world_location.update_attributes(name: 'Australia')
    assert_equal 'new-holland', world_location.slug
  end

  test "should not include apostrophes in slug" do
    world_location = create(:world_location, name: "Bob's bike")
    assert_equal 'bobs-bike', world_location.slug
  end

  test "has name of it's world location type as display type" do
    world_location_type = WorldLocationType::Country
    world_location_type.stubs(:name).returns('The Moon')
    world_location = build(:world_location, world_location_type: world_location_type)
    assert_equal "The Moon", world_location.display_type
  end

  test "#with_announcements should return the world locations with announcements" do
    world_location = create(:world_location)
    other_world_location = create(:world_location)

    item_a = create(:published_news_article, world_locations: [world_location])
    item_b = create(:published_news_article, world_locations: [world_location])

    assert_equal 1, WorldLocation.with_announcements.count
  end

  test 'ordered_by_name sorts by the I18n.default_locale translation for name' do
    world_location_1 = create(:world_location, name: 'Neverland')
    world_location_2 = create(:world_location, name: 'Middle Earth')
    world_location_3 = create(:world_location, name: 'Narnia')

    I18n.with_locale(I18n.default_locale) do
      assert_equal [world_location_2, world_location_3, world_location_1], WorldLocation.ordered_by_name
    end
  end

  test 'ordered_by_name uses the I18n.default_locale ordering even if the current locale is not I18n.default_locale' do
    world_location_1 = create(:world_location, name: 'Neverland')
    world_location_2 = create(:world_location, name: 'Middle Earth')
    world_location_3 = create(:world_location, name: 'Narnia')

    I18n.with_locale(:fr) do
      world_location_1.name = 'Pays imaginaire'; world_location_1.save
      world_location_2.name = 'Terre du Milieu'; world_location_2.save

      assert_equal [world_location_2, world_location_3, world_location_1], WorldLocation.ordered_by_name
    end
  end

  test "all_by_type should group world locations by type sorting the types by their sort order" do
    territory_type = WorldLocationType::OverseasTerritory
    country_type = WorldLocationType::Country

    location_1 = create(:world_location, world_location_type: territory_type)
    location_2 = create(:world_location, world_location_type: country_type)
    location_3 = create(:world_location, world_location_type: country_type)

    assert_equal [ [country_type, [location_2, location_3]] , [territory_type, [location_1]] ], WorldLocation.all_by_type
  end

  test "all_by_type should group world locations by type sorting the locations by their name" do
    territory_type = WorldLocationType::OverseasTerritory
    country_type = WorldLocationType::Country

    location_1 = create(:world_location, world_location_type: territory_type, name: 'Neverland')
    location_2 = create(:world_location, world_location_type: country_type, name: 'Narnia')
    location_3 = create(:world_location, world_location_type: country_type, name: 'Middle Earth')

    assert_equal [ [country_type, [location_3, location_2]] , [territory_type, [location_1]] ], WorldLocation.all_by_type
  end

  test '#featured_edition_world_locations should return editions featured against this world_location' do
    world_location = create(:world_location)
    other_world_location = create(:world_location)

    item_a = create(:published_news_article)
    item_b = create(:published_speech)
    item_c = create(:published_policy)

    create(:featured_edition_world_location, world_location: world_location, edition: item_a)
    create(:featured_edition_world_location, world_location: world_location, edition: item_b)
    create(:featured_edition_world_location, world_location: other_world_location, edition: item_c)

    assert_equal [item_a, item_b], world_location.featured_edition_world_locations.map(&:edition)
  end

  test '#featured_edition_world_locations should only return published editions' do
    world_location = create(:world_location)

    item_a = create(:published_news_article)
    item_b = create(:draft_news_article)

    create(:featured_edition_world_location, world_location: world_location, edition: item_a)
    create(:featured_edition_world_location, world_location: world_location, edition: item_b)

    assert_equal [item_a], world_location.featured_edition_world_locations.map(&:edition)
  end

  test '#featured_edition_world_locations should only return featured editions' do
    world_location = create(:world_location)

    item_a = create(:published_news_article)
    item_b = create(:published_news_article)

    create(:edition_world_location, world_location: world_location, edition: item_a)
    create(:featured_edition_world_location, world_location: world_location, edition: item_b)

    assert_equal [item_b], world_location.featured_edition_world_locations.map(&:edition)
  end
end
