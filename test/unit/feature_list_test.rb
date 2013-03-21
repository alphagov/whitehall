require "test_helper"

class FeatureListTest < ActiveSupport::TestCase
  test "features are given an ordering if none set" do
    feature_list = build(:feature_list, locale: :en)
    feature_list.features << build(:feature)
    feature_list.features << build(:feature)
    feature_list.features << build(:feature, ordering: 7)
    assert_equal [1, 2, 7], feature_list.features.map(&:ordering)
  end

  test "features are given an ordering when assigning a list" do
    feature_list = build(:feature_list, locale: :en)
    feature_list.features = [build(:feature), build(:feature)]
    assert_equal [1,2], feature_list.features.map(&:ordering)
    feature_list.save
  end

  test "features returned in order" do
    features = [
      create(:feature, ordering: 2),
      create(:feature, ordering: 3),
      create(:feature, ordering: 1)
    ]
    feature_list = create(:feature_list, locale: :en, features: features)
    feature_list.reload
    assert_equal [1, 2, 3], feature_list.features.map(&:ordering)
  end

  test "can re-order features" do
    feature_list = create(:feature_list, locale: :en)
    feature_list.features << create(:feature)
    feature_list.features << create(:feature)

    feature1, feature2 = feature_list.features

    feature_list.reload
    assert_equal [feature1, feature2], feature_list.features

    feature_list.reorder!([feature2.id, feature1.id])

    feature_list.reload
    assert_equal [feature2, feature1], feature_list.features
  end

  test "features which are not part of the feature list are ignored when re-ordering" do
    f1, f2, f3 = [create(:feature), create(:feature), create(:feature)]

    feature_list_1 = create(:feature_list, locale: :en, features: [f1, f2])
    feature_list_2 = create(:feature_list, locale: :fr, features: [f3])

    refute_nil f3_original_ordering = f3.ordering

    feature_list_1.reorder!([f2.id, f3.id, f1.id])

    assert_equal f3_original_ordering, f3.reload.ordering
    assert_equal [f2, f1], feature_list_1.reload.features
  end

  test "returns featurable editions" do
    country = create(:country)
    published = create(:published_publication, world_locations: [country])
    draft = create(:draft_publication, world_locations: [country])
    feature_list = create(:feature_list, featurable: country, locale: :en)
    assert_equal [published], feature_list.featurable_editions
  end

  test "only returns featurable documents with translations in the same locale" do
    country = create(:country)
    published = create(:published_publication, world_locations: [country])
    french_publication = create(:published_publication, world_locations: [country], translated_into: [:fr])
    published = create(:published_publication, world_locations: [country])
    feature_list = create(:feature_list, featurable: country, locale: :fr)
    assert_equal [french_publication], feature_list.featurable_editions
  end

  test '#features should still return featured documents after republication' do
    world_location = create(:world_location)

    item_a = create(:published_news_article, world_locations: [world_location])
    item_b = create(:published_news_article, world_locations: [world_location])

    feature_list = create(:feature_list, featurable: world_location, locale: :en)
    create(:feature, feature_list: feature_list, document: item_b.document)

    editor = create(:departmental_editor)
    new_draft = item_b.create_draft(editor)
    new_draft.minor_change = true
    new_draft.publish_as(editor, force: true)

    feature_list.reload

    assert_equal [new_draft.document], feature_list.features.map(&:document)
  end

  test '#published_features only returns features where there is a published edition' do
    published = create(:published_news_article)
    draft = create(:draft_news_article)

    feature_list = create(:feature_list, locale: :en)
    feature_list.features << build(:feature, document: published.document)
    feature_list.features << build(:feature, document: draft.document)

    assert_equal [[published], [draft]], feature_list.features.map {|f| f.document.editions }
    assert_equal [[published]], feature_list.published_features.map {|f| f.document.editions }
  end

  test '#published_features only excludes features which have ended' do
    published = create(:published_news_article)

    feature_list = create(:feature_list, locale: :en)
    feature_list.features << build(:feature, document: published.document, ended_at: Time.zone.now)

    assert_equal [], feature_list.published_features.map {|f| f.document.editions }
  end

end