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
    world_location_type = WorldLocationType::WorldLocation
    world_location_type.stubs(:name).returns('The Moon')
    world_location = build(:world_location, world_location_type: world_location_type)
    assert_equal "The Moon", world_location.display_type
  end

  test "#with_announcements should return the world locations with announcements" do
    world_location = create(:world_location)
    other_world_location = create(:world_location)

    item_a = create(:published_news_article, world_locations: [world_location])
    item_b = create(:published_news_article, world_locations: [world_location])

    assert_equal [world_location], WorldLocation.with_announcements
  end

  test "#with_publications should return the world locations with publications" do
    world_location = create(:world_location)
    other_world_location = create(:world_location)

    item_a = create(:published_publication, world_locations: [world_location])
    item_b = create(:published_publication, world_locations: [world_location])

    assert_same_elements [world_location], WorldLocation.with_publications
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
    world_location_type = WorldLocationType::WorldLocation
    delegation_type = WorldLocationType::InternationalDelegation

    location_1 = create(:world_location, world_location_type: world_location_type)
    location_2 = create(:world_location, world_location_type: delegation_type)
    location_3 = create(:world_location, world_location_type: delegation_type)

    assert_equal [ [world_location_type, [location_1]] , [delegation_type, [location_2, location_3]] ], WorldLocation.all_by_type
  end

  test "all_by_type should group world locations by type sorting the locations by their name" do
    world_location_type = WorldLocationType::WorldLocation
    delegation_type = WorldLocationType::InternationalDelegation

    location_1 = create(:world_location, world_location_type: delegation_type, name: 'Neverland')
    location_2 = create(:world_location, world_location_type: world_location_type, name: 'Narnia')
    location_3 = create(:world_location, world_location_type: world_location_type, name: 'Middle Earth')

    assert_equal [ [world_location_type, [location_3, location_2]] , [delegation_type, [location_1]] ], WorldLocation.all_by_type
  end

  test "#feature_list_for_locale should return the feature list for the given locale, or build one if not" do
    english = build(:feature_list, locale: :en)
    french = build(:feature_list, locale: :fr)

    location = create(:world_location, feature_lists: [english, french])
    assert_equal english, location.feature_list_for_locale(:en)
    assert_equal french, location.feature_list_for_locale(:fr)
    arabic = location.feature_list_for_locale(:ar)
    assert_equal :ar, arabic.locale
    assert_equal location, arabic.featurable
    refute arabic.persisted?
  end

  test "should be creatable with mainstream link data" do
    params = {
      mainstream_links_attributes: [
        {url: "https://www.gov.uk/blah/blah",
         title: "Blah blah"},
        {url: "https://www.gov.uk/wah/wah",
         title: "Wah wah"},
      ]
    }

    world_location = create(:world_location, params)

    links = world_location.mainstream_links
    assert_equal 2, links.count
    assert_equal "https://www.gov.uk/blah/blah", links[0].url
    assert_equal "Blah blah", links[0].title
    assert_equal "https://www.gov.uk/wah/wah", links[1].url
    assert_equal "Wah wah", links[1].title
  end

  test 'should ignore blank mainstream link attributes' do
    params = {
      mainstream_links_attributes: [
        {url: "",
         title: ""}
      ]
    }
    world_location = build(:world_location, params)
    assert world_location.valid?
  end

  test 'mainstream links are returned in order of creation' do
    world_location = create(:world_location)
    link_1 = create(:mainstream_link, linkable: world_location, title: '2 days ago', created_at: 2.days.ago)
    link_2 = create(:mainstream_link, linkable: world_location, title: '12 days ago', created_at: 12.days.ago)
    link_3 = create(:mainstream_link, linkable: world_location, title: '1 hour ago', created_at: 1.hour.ago)
    link_4 = create(:mainstream_link, linkable: world_location, title: '2 hours ago', created_at: 2.hours.ago)
    link_5 = create(:mainstream_link, linkable: world_location, title: '20 minutes ago', created_at: 20.minutes.ago)
    link_6 = create(:mainstream_link, linkable: world_location, title: '2 years ago', created_at: 2.years.ago)

    assert_equal [link_6, link_2, link_1, link_4, link_3, link_5], world_location.mainstream_links
    assert_equal [link_6, link_2, link_1, link_4, link_3], world_location.mainstream_links.only_the_initial_set
  end

  test "has removeable translations" do
    world_location = create(:world_location, translated_into: [:fr, :es])
    world_location.remove_translations_for(:fr)
    refute world_location.translated_locales.include?(:fr)
    assert world_location.translated_locales.include?(:es)
  end

  test 'we can find those that are countries' do
    world_location = create(:world_location)
    international_delegation = create(:international_delegation)

    countries = WorldLocation.countries
    assert countries.include?(world_location)
    refute countries.include?(international_delegation)
  end

  test 'we can find those that represent something geographic (if not neccessarily a world location)' do
    world_location = create(:world_location)
    international_delegation = create(:international_delegation)

    geographic = WorldLocation.geographical
    assert geographic.include?(world_location)
    refute geographic.include?(international_delegation)
  end

  test 'adds world location to search index on creating if it is active' do
    active_location = build(:world_location, active: true)

    Searchable::Index.expects(:later).with(active_location)

    active_location.save
  end

  test 'does not add world location to search index on creating if it is not active' do
    inactive_location = build(:world_location, active: false)

    Searchable::Index.expects(:later).with(inactive_location).never

    inactive_location.save
  end

  test 'adds world location to search index on updating if it is active' do
    active_location = create(:world_location, active: true)

    Searchable::Index.expects(:later).with(active_location)

    active_location.name = 'Hat land'
    active_location.save
  end

  test 'does not add world location to search index on updating if it is inactive' do
    inactive_location = create(:world_location, active: false)

    Searchable::Index.expects(:later).with(inactive_location).never

    inactive_location.name = 'Hat land'
    inactive_location.save
  end

  test 'removes world location from search index on updating if it is becoming inactive' do
    inactive_location = create(:world_location, active: true)

    Searchable::Delete.expects(:later).with(inactive_location)

    inactive_location.active = false
    inactive_location.save
  end

  test 'removes world location role from search index on destroying if it is active' do
    active_location = create(:world_location, active: true)
    Searchable::Delete.expects(:later).with(active_location)
    active_location.destroy
  end

  test 'removes world location role from search index on destroying if it is inactive' do
    inactive_location = create(:world_location, active: false)
    Searchable::Delete.expects(:later).with(inactive_location)
    inactive_location.destroy
  end

  test 'search index data for a world location includes name, mission statement, the correct link and format' do
    location = build(:world_location, name: 'hat land', slug: 'hat-land', mission_statement: 'helping people in hat land find out about other clothing')

    assert_equal({'title' => 'hat land',
                  'link' => '/government/world/hat-land',
                  'indexable_content' => 'helping people in hat land find out about other clothing',
                  'format' => 'world_location',
                  'description' => '',
                  'slug' => 'hat-land'}, location.search_index)
  end

  test 'search index includes data for all active locations' do
    active_location = create(:world_location, name: 'hat land', mission_statement: 'helping people in hat land find out about other clothing', active: true)
    active_location = create(:world_location, name: 'sheep land', mission_statement: 'helping people in sheep land find out about other animals', active: false)

    assert_equal 1, WorldLocation.search_index.to_a.length
    assert_equal ['/government/world/hat-land'], WorldLocation.search_index.map {|search_data| search_data['link']}
  end

  test 'only one feature list per language per world location' do
    world_location1 = create(:world_location)
    world_location2 = create(:world_location)
    FeatureList.create!(featurable: world_location1, locale: :en)
    FeatureList.create!(featurable: world_location1, locale: :fr)
    FeatureList.create!(featurable: world_location2, locale: :en)
    assert_raises ActiveRecord::RecordInvalid do
      FeatureList.create!(featurable: world_location2, locale: :en)
    end
  end
end
