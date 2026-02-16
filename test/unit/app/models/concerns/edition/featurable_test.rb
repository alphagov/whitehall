require "test_helper"

class FeaturableTestEdition < Edition
  include Edition::Featurable
end

class Edition::FeaturableTest < ActiveSupport::TestCase
  test "#feature_list_for_locale should return the feature list for the given locale, or build one if not" do
    english = build(:feature_list, locale: :en)
    french = build(:feature_list, locale: :fr)

    edition = FeaturableTestEdition.new(feature_lists: [english, french])

    assert_equal english, edition.feature_list_for_locale(:en)
    assert_equal french, edition.feature_list_for_locale(:fr)
    arabic = edition.feature_list_for_locale(:ar)
    assert_equal "ar", arabic.locale
    assert_equal edition, arabic.featurable
    assert_not arabic.persisted?
  end

  test "#feature_list_for_locale should only build one feature list for a given locale when called multiple times" do
    edition = FeaturableTestEdition.new

    edition.feature_list_for_locale(:en)
    edition.feature_list_for_locale(:en)

    assert_equal 1, edition.feature_lists.size
  end

  test "get features with locale should find feature list if present" do
    edition = FeaturableTestEdition.new
    edition.document = Document.new(content_id: SecureRandom.uuid)
    edition.document.save!(validate: false)
    edition.save!(validate: false)

    feature_list = create(:feature_list, featurable: edition, locale: :fr)

    assert_equal feature_list, edition.load_or_create_feature_list(:fr)
  end

  test "get features should create feature list if not present" do
    edition = FeaturableTestEdition.new
    edition.document = Document.new(content_id: SecureRandom.uuid)
    edition.document.save!(validate: false)
    edition.save!(validate: false)

    edition.load_or_create_feature_list(:fr)
    edition.reload
    assert_equal %w[fr], edition.feature_lists.map(&:locale)
  end
end
