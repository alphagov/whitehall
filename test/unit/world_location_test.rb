require "test_helper"

class WorldLocationTest < ActiveSupport::TestCase
  should_protect_against_xss_and_content_attacks_on :world_location, :name

  test "should be invalid without a name" do
    world_location = build(:world_location, name: nil)
    assert_not world_location.valid?
  end

  test "should be invalid without a world location type" do
    world_location = build(:world_location, world_location_type: nil)
    assert_not world_location.valid?
  end

  test "should set a slug from the name" do
    world_location = create(:world_location, name: "Costa Rica")
    assert_equal "costa-rica", world_location.slug
  end

  test "should not change the slug when the name is changed" do
    world_location = create(:world_location, name: "New Holland")
    world_location.update!(name: "Australia")
    assert_equal "new-holland", world_location.slug
  end

  test "should not include apostrophes in slug" do
    world_location = create(:world_location, name: "Bob's bike")
    assert_equal "bobs-bike", world_location.slug
  end

  test "should set an analytics identifier on create" do
    world_location = create(:world_location, name: "Costa Rica")
    assert_equal "WL#{world_location.id}", world_location.analytics_identifier
  end

  test "has name of its world location type as display type" do
    world_location_type = WorldLocationType::WorldLocation
    world_location_type.stubs(:name).returns("The Moon")
    world_location = build(:world_location, world_location_type: world_location_type)
    assert_equal "The Moon", world_location.display_type
  end

  test ".worldwide_organisations_with_sponsoring_organisations returns all related organisations" do
    world_location = create(:world_location, :with_worldwide_organisations)
    related_organisations = world_location.worldwide_organisations +
      world_location.worldwide_organisations
        .map { |orgs| orgs.sponsoring_organisations.to_a }.flatten

    assert_equal related_organisations, world_location.worldwide_organisations_with_sponsoring_organisations
  end

  test "#with_announcements should return the world locations with announcements" do
    world_location = create(:world_location)
    _other_world_location = create(:world_location)

    create(:published_news_article, world_locations: [world_location])
    create(:published_news_article, world_locations: [world_location])

    assert_equal [world_location], WorldLocation.with_announcements
  end

  test "#with_publications should return the world locations with publications" do
    world_location = create(:world_location)
    _other_world_location = create(:world_location)

    create(:published_publication, world_locations: [world_location])
    create(:published_publication, world_locations: [world_location])

    assert_same_elements [world_location], WorldLocation.with_publications
  end

  test "ordered_by_name sorts by the I18n.default_locale translation for name" do
    world_location1 = create(:world_location, name: "Neverland")
    world_location2 = create(:world_location, name: "Middle Earth")
    world_location3 = create(:world_location, name: "Narnia")

    I18n.with_locale(I18n.default_locale) do
      assert_equal [world_location2, world_location3, world_location1], WorldLocation.ordered_by_name
    end
  end

  test "ordered_by_name uses the I18n.default_locale ordering even if the current locale is not I18n.default_locale" do
    world_location1 = create(:world_location, name: "Neverland")
    world_location2 = create(:world_location, name: "Middle Earth")
    world_location3 = create(:world_location, name: "Narnia")

    I18n.with_locale(:fr) do
      world_location1.name = "Pays imaginaire"
      world_location1.save!
      world_location2.name = "Terre du Milieu"
      world_location2.save!

      assert_equal [world_location2, world_location3, world_location1], WorldLocation.ordered_by_name
    end
  end

  test "all_by_type should group world locations by type sorting the types by their sort order and locations by their name" do
    world_location_type = WorldLocationType::WorldLocation
    delegation_type = WorldLocationType::InternationalDelegation

    location1 = create(:world_location, world_location_type: world_location_type, name: "Narnia")
    location2 = create(:world_location, world_location_type: delegation_type, name: "Neverland")
    location3 = create(:world_location, world_location_type: world_location_type, name: "Middle Earth")

    assert_equal [[world_location_type, [location3, location1]], [delegation_type, [location2]]], WorldLocation.all_by_type
  end

  test "we can find those that are countries" do
    world_location = create(:world_location)
    international_delegation = create(:international_delegation)

    countries = WorldLocation.countries
    assert countries.include?(world_location)
    assert_not countries.include?(international_delegation)
  end

  test "we can find those that represent something geographic (if not neccessarily a world location)" do
    world_location = create(:world_location)
    international_delegation = create(:international_delegation)

    geographic = WorldLocation.geographical
    assert geographic.include?(world_location)
    assert_not geographic.include?(international_delegation)
  end

  test "adds world location to search index on creating if it is active and an international delegation" do
    active_location = build(:international_delegation, active: true)

    Whitehall::SearchIndex.expects(:add).at_least_once.with(active_location)
    Whitehall::SearchIndex.expects(:add).at_least_once.with(active_location.world_location_news)

    active_location.save!
  end

  test "does not add world location to search index on creating if it is active and a world location type" do
    active_world_location = build(:world_location, active: true)

    Whitehall::SearchIndex.expects(:add).at_least_once.with(active_world_location.world_location_news)
    Whitehall::SearchIndex.expects(:add).with(active_world_location).never

    active_world_location.save!
  end

  test "does not add world location to search index on creating if it is not active" do
    inactive_location = build(:world_location, active: false)

    Whitehall::SearchIndex.expects(:add).with(inactive_location).never

    inactive_location.save!
  end

  test "adds world location to search index on updating if it is active and an international delegation" do
    active_location = create(:international_delegation, active: true)

    Whitehall::SearchIndex.expects(:add).with(active_location)

    active_location.name = "Hat land"
    active_location.save!
  end

  test "does not add world location to search index on updating if it is inactive" do
    inactive_location = create(:world_location, active: false)

    Whitehall::SearchIndex.expects(:add).with(inactive_location).never

    inactive_location.name = "Hat land"
    inactive_location.save!
  end

  test "removes world location from search index on updating if it is becoming inactive" do
    inactive_location = create(:international_delegation, active: true)

    Whitehall::SearchIndex.expects(:delete).with(inactive_location)

    inactive_location.active = false
    inactive_location.save!
  end

  test "removes world location role from search index on destroying if it is active" do
    active_location = create(:international_delegation, active: true)
    Whitehall::SearchIndex.expects(:delete).with(active_location)
    active_location.destroy!
  end

  test "removes world location role from search index on destroying if it is inactive" do
    inactive_location = create(:world_location, active: false)
    Whitehall::SearchIndex.expects(:delete).with(inactive_location)
    inactive_location.destroy!
  end

  test "search index data for a world location includes name, description, the correct link and format" do
    world_location_news = build(:world_location_news, title: "hat land and the UK")
    location = build(:world_location, name: "hat land", slug: "hat-land", world_location_news: world_location_news)

    assert_equal(
      { "title" => "hat land and the UK",
        "link" => "/world/hat-land",
        "description" => "Services if you're visiting, studying, working or living in hat land. Includes information about trading with and doing business in the UK and hat land.",
        "format" => "world_location",
        "slug" => "hat-land" },
      location.search_index,
    )
  end

  test "search index description for a international delegation world location" do
    international_delegation = build(
      :international_delegation,
      name: "UK Mission to Somewhere",
      slug: "uk-mission-to-somewhere",
    )

    assert_equal "Updates, news and events from the UK government in UK Mission to Somewhere.",
                 international_delegation.search_index["description"]
  end

  test "search index includes data only for active locations" do
    create(:international_delegation, name: "hat land", active: true)
    create(:international_delegation, name: "sheep land", active: false)

    assert_equal 1, WorldLocation.search_index.to_a.length
    assert_equal ["/world/hat-land"], (WorldLocation.search_index.map { |search_data| search_data["link"] })
  end

  test "only sends en version to the publishing api" do
    world_location = create(:world_location, name: "Neverland")

    I18n.with_locale(:fr) do
      world_location.name = "Pays imaginaire"
      world_location.save!
    end

    PublishingApiWorker.expects(:perform_async).with(
      "WorldLocation",
      world_location.id,
      nil,
      "en",
    )
    world_location.name = "Test"
    world_location.send(:run_callbacks, :commit)
  end
end
