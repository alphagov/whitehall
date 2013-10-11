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

    assert feature_list.reorder!([feature2.id, feature1.id])
    refute feature_list.errors.any?

    feature_list.reload
    assert_equal [feature2, feature1], feature_list.features
  end

  test "validation errors when reordering features are propogated" do
    f1 = create(:feature)
    feature_list = create(:feature_list, locale: :en, features: [f1])
    f1.document = nil
    Mocha::Configuration.allow(:stubbing_non_existent_method) do
      feature_list.features.stubs(:find_by_id!).with(f1.id).returns(f1)
      refute feature_list.reorder!([f1.id])
      assert_match /Can't reorder because '.*'/, feature_list.errors.full_messages.to_sentence
    end
  end

  test "reordering fails if features which are not part of the feature list are referenced when re-ordering" do
    f1, f2, f3 = [create(:feature), create(:feature), create(:feature)]

    feature_list_1 = create(:feature_list, locale: :en, features: [f1, f2])
    feature_list_2 = create(:feature_list, locale: :fr, features: [f3])

    refute_nil f3_original_ordering = f3.ordering

    refute feature_list_1.reorder!([f2.id, f3.id, f1.id])
    assert_match /Can't reorder because '.*'/, feature_list_1.errors[:base].to_sentence

    assert_equal f3_original_ordering, f3.reload.ordering
    assert_equal [f1, f2], feature_list_1.reload.features
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
    force_publish(new_draft)

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
