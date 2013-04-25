require 'test_helper'

class Edition::FeaturableTest < ActiveSupport::TestCase
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
end
