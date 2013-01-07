require 'test_helper'

class WorldLocationTest < ActiveSupport::TestCase
  should_protect_against_xss_and_content_attacks_on :name, :about

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

  test "should group world locations by type sorted by order" do
    territory_type = WorldLocationType::OverseasTerritory
    country_type = WorldLocationType::Country

    location_1 = create(:world_location, world_location_type: territory_type)
    location_2 = create(:world_location, world_location_type: country_type)
    location_3 = create(:world_location, world_location_type: country_type)

    assert_equal [ [country_type, [location_2, location_3]] , [territory_type, [location_1]] ], WorldLocation.all_by_type
  end

  test '#featured_news_articles should return news articles featured against this world_location' do
    world_location = create(:world_location)
    other_world_location = create(:world_location)

    news_a = create(:published_news_article)
    news_b = create(:published_news_article)
    news_c = create(:published_news_article)

    create(:edition_world_location, world_location: world_location, edition: news_a, featured: true)
    create(:edition_world_location, world_location: world_location, edition: news_b, featured: true)
    create(:edition_world_location, world_location: other_world_location, edition: news_c, featured: true)

    assert_equal [news_a, news_b], world_location.featured_news_articles
  end

  test '#featured_news_articles should only return published articles' do
    world_location = create(:world_location)

    news_a = create(:published_news_article)
    news_b = create(:draft_news_article)

    create(:edition_world_location, world_location: world_location, edition: news_a, featured: true)
    create(:edition_world_location, world_location: world_location, edition: news_b, featured: true)

    assert_equal [news_a], world_location.featured_news_articles
  end

  test '#featured_news_articles should only return featured articles' do
    world_location = create(:world_location)

    news_a = create(:published_news_article)
    news_b = create(:published_news_article)

    create(:edition_world_location, world_location: world_location, edition: news_a, featured: false)
    create(:edition_world_location, world_location: world_location, edition: news_b, featured: true)

    assert_equal [news_b], world_location.featured_news_articles
  end
end
