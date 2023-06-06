require "test_helper"

class Edition::FeaturableTest < ActiveSupport::TestCase
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

  test "#feature_list_for_locale should only build one feature list for a given locale when called multiple times" do
    world_location_news = build(:world_location_news)
    create(:world_location, world_location_news:)
    world_location_news.feature_list_for_locale(:en)
    world_location_news.feature_list_for_locale(:en)

    assert_equal 1, world_location_news.feature_lists.size
  end

  test "get features with locale should find feature list if present" do
    world_location_news = build(:world_location_news)
    create(:world_location, world_location_news:)
    feature_list = create(:feature_list, featurable: world_location_news, locale: :fr)

    assert_equal feature_list, world_location_news.load_or_create_feature_list(:fr)
  end

  test "get features should create feature list if not present" do
    world_location_news = build(:world_location_news)
    create(:world_location, world_location_news:)
    world_location_news.load_or_create_feature_list(:fr)
    world_location_news.reload
    assert_equal %w[fr], world_location_news.feature_lists.map(&:locale)
  end
end
