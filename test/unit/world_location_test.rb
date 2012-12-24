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

  test 'should not be featured' do
    world_location = create(:world_location, name: 'Cascadia')
    refute world_location.featured?
  end

  test 'should be featured if name matches hard-coded list' do
    %w[ Spain ].each do |name|
      assert create(:world_location, name: name).featured?
    end
  end

  test 'should return featured world locations' do
    %w[ Spain Cascadia Virginia ].each do |name|
      create(:world_location, name: name)
    end
    assert_equal 1, WorldLocation.featured.length
  end

  test 'should return hard-coded urls for featured world locations' do
    spain = create(:world_location, name: 'Spain')
    assert_equal %w[ http://ukinspain.fco.gov.uk ], spain.urls
  end

  test 'should return no urls for world locations that are not featured.' do
    world_location = create(:world_location)
    assert_equal [], world_location.urls
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
