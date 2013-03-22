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

  test '#featured_edition_world_locations should still return featured editions after republication' do
    world_location = create(:world_location)

    item_a = create(:published_news_article)
    item_b = create(:published_news_article)

    create(:edition_world_location, world_location: world_location, edition: item_a)
    create(:featured_edition_world_location, world_location: world_location, edition: item_b)

    item_b.reload

    editor = create(:departmental_editor)
    new_draft = item_b.create_draft(editor)
    new_draft.minor_change = true
    new_draft.publish_as(editor, force: true)

    world_location.reload

    assert_equal [new_draft.reload], world_location.featured_edition_world_locations.map(&:edition)
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

  test "has removeable translations" do
    world_location = create(:world_location, translated_into: [:fr, :es])
    world_location.remove_translations_for(:fr)
    refute world_location.translated_locales.include?(:fr)
    assert world_location.translated_locales.include?(:es)
  end

  test 'we can find those that are countries' do
    country = create(:country)
    overseas_territory = create(:overseas_territory)
    international_delegation = create(:international_delegation)

    countries = WorldLocation.countries
    assert countries.include?(country)
    refute countries.include?(overseas_territory)
    refute countries.include?(international_delegation)
  end

  test 'we can find those that represent something geographic (if not neccessarily a country)' do
    country = create(:country)
    overseas_territory = create(:overseas_territory)
    international_delegation = create(:international_delegation)

    geographic = WorldLocation.geographical
    assert geographic.include?(country)
    assert geographic.include?(overseas_territory)
    refute geographic.include?(international_delegation)
  end

  test 'adds world location to search index on creating if it is active' do
    active_location = build(:world_location, active: true)

    search_index_data = stub('search index data')
    active_location.stubs(:search_index).returns(search_index_data)
    Rummageable.expects(:index).with(search_index_data, Whitehall.government_search_index_path)

    active_location.save
  end

  test 'does not add world location to search index on creating if it is not active' do
    inactive_location = build(:world_location, active: false)

    search_index_data = stub('search index data')
    inactive_location.stubs(:search_index).returns(search_index_data)
    Rummageable.expects(:index).with(search_index_data, Whitehall.government_search_index_path).never

    inactive_location.save
  end

  test 'adds world location to search index on updating if it is active' do
    active_location = create(:world_location, active: true)

    search_index_data = stub('search index data')
    active_location.stubs(:search_index).returns(search_index_data)
    Rummageable.expects(:index).with(search_index_data, Whitehall.government_search_index_path)

    active_location.name = 'Hat land'
    active_location.save
  end

  test 'does not add world location to search index on updating if it is inactive' do
    inactive_location = create(:world_location, active: false)

    search_index_data = stub('search index data')
    inactive_location.stubs(:search_index).returns(search_index_data)
    Rummageable.expects(:index).with(search_index_data, Whitehall.government_search_index_path).never

    inactive_location.name = 'Hat land'
    inactive_location.save
  end

  test 'removes world location from search index on updating if it is becoming inactive' do
    inactive_location = create(:world_location, active: true)

    search_index_data = stub('search index data')
    inactive_location.stubs(:search_index).returns(search_index_data)
    Rummageable.expects(:delete).with("/government/world/#{inactive_location.slug}", Whitehall.government_search_index_path)

    inactive_location.active = false
    inactive_location.save
  end

  test 'removes world location role from search index on destroying if it is active' do
    active_location = create(:world_location, active: true)
    Rummageable.expects(:delete).with("/government/world/#{active_location.slug}", Whitehall.government_search_index_path)
    active_location.destroy
  end

  test 'removes world location role from search index on destroying if it is inactive' do
    inactive_location = create(:world_location, active: false)
    Rummageable.expects(:delete).with("/government/world/#{inactive_location.slug}", Whitehall.government_search_index_path)
    inactive_location.destroy
  end

  test 'search index data for a world locaiton includes name, mission statement, the correct link and format' do
    location = build(:world_location, name: 'hat land', slug: 'hat-land', mission_statement: 'helping people in hat land find out about other clothing')

    assert_equal({'title' => location.name,
                  'link' => '/government/world/hat-land',
                  'indexable_content' => 'helping people in hat land find out about other clothing',
                  'format' => 'world_location',
                  'description' => ''}, location.search_index)
  end

  test 'search index includes data for all active locations' do
    active_location = create(:world_location, name: 'hat land', mission_statement: 'helping people in hat land find out about other clothing', active: true)
    active_location = create(:world_location, name: 'sheep land', mission_statement: 'helping people in sheep land find out about other animals', active: false)

    assert_equal 1, WorldLocation.search_index.to_a.length
    assert_equal ['/government/world/hat-land'], WorldLocation.search_index.map {|search_data| search_data['link']}
  end
end
