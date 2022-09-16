require "test_helper"

class WorldLocationNewsTest < ActiveSupport::TestCase
  should_protect_against_xss_and_content_attacks_on :world_location_news_with_stubbed_slug, :mission_statement

  test "#feature_list_for_locale should return the feature list for the given locale, or build one if not" do
    english = build(:feature_list, locale: :en)
    french = build(:feature_list, locale: :fr)

    world_location_news = build(:world_location_news, feature_lists: [english, french])
    create(:world_location, world_location_news:)
    assert_equal english, world_location_news.feature_list_for_locale(:en)
    assert_equal french, world_location_news.feature_list_for_locale(:fr)
    arabic = world_location_news.feature_list_for_locale(:ar)
    assert_equal "ar", arabic.locale
    assert_equal world_location_news, arabic.featurable
    assert_not arabic.persisted?
  end

  test "should be creatable with featured link data" do
    params = {
      featured_links_attributes: [
        { url: "https://www.gov.uk/blah/blah",
          title: "Blah blah" },
        { url: "https://www.gov.uk/wah/wah",
          title: "Wah wah" },
      ],
    }

    world_location_news = build(:world_location_news, params)
    world_location = create(:world_location, world_location_news:)

    links = world_location.world_location_news.featured_links
    assert_equal 2, links.count
    assert_equal "https://www.gov.uk/blah/blah", links[0].url
    assert_equal "Blah blah", links[0].title
    assert_equal "https://www.gov.uk/wah/wah", links[1].url
    assert_equal "Wah wah", links[1].title
  end

  test "should ignore blank featured link attributes" do
    params = {
      featured_links_attributes: [
        { url: "",
          title: "" },
      ],
    }
    world_location_news = build(:world_location_news, params)
    create(:world_location, world_location_news:)
    assert world_location_news.valid?
  end

  test "featured links are returned in order of creation" do
    world_location_news = build(:world_location_news)
    create(:world_location, world_location_news:)
    link1 = create(:featured_link, linkable: world_location_news, title: "2 days ago", created_at: 2.days.ago)
    link2 = create(:featured_link, linkable: world_location_news, title: "12 days ago", created_at: 12.days.ago)
    link3 = create(:featured_link, linkable: world_location_news, title: "1 hour ago", created_at: 1.hour.ago)
    link4 = create(:featured_link, linkable: world_location_news, title: "2 hours ago", created_at: 2.hours.ago)
    link5 = create(:featured_link, linkable: world_location_news, title: "20 minutes ago", created_at: 20.minutes.ago)
    link6 = create(:featured_link, linkable: world_location_news, title: "2 years ago", created_at: 2.years.ago)

    assert_equal [link6, link2, link1, link4, link3, link5], world_location_news.featured_links
    assert_equal [link6, link2, link1, link4, link3], world_location_news.featured_links.only_the_initial_set
  end

  test "only one feature list per language per world location" do
    world_location_news1 = build(:world_location_news)
    create(:world_location, world_location_news: world_location_news1)
    world_location_news2 = build(:world_location_news)
    create(:world_location, world_location_news: world_location_news2)

    FeatureList.create!(featurable: world_location_news1, locale: :en)
    FeatureList.create!(featurable: world_location_news1, locale: :fr)
    FeatureList.create!(featurable: world_location_news2, locale: :en)
    assert_raise ActiveRecord::RecordInvalid do
      FeatureList.create!(featurable: world_location_news2, locale: :en)
    end
  end
end
