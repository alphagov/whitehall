require "test_helper"

class FeatureListTest < ActiveSupport::TestCase
  test "to_s returns name and locale for non-editionable parents (e.g. TopicalEvent)" do
    topical_event = build(:topical_event, name: "Mars Exploration")
    feature_list = build(:feature_list, featurable: topical_event, locale: :en)
    assert_equal "Mars Exploration (en)", feature_list.to_s
  end

  test "to_s returns title and locale for editionable parents (e.g. StandardEdition)" do
    edition = build(:standard_edition, title: "Mission to the Moon")
    feature_list = build(:feature_list, featurable: edition, locale: :fr)

    assert_equal "Mission to the Moon (fr)", feature_list.to_s
  end

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
    assert_equal [1, 2], feature_list.features.map(&:ordering)
    feature_list.save!
  end

  test "features returned in order" do
    features = [
      create(:feature, ordering: 2),
      create(:feature, ordering: 3),
      create(:feature, ordering: 1),
    ]
    feature_list = create(:feature_list, locale: :en, features:)
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
    assert_not feature_list.errors.any?

    feature_list.reload
    assert_equal [feature2, feature1], feature_list.features
  end

  test "republishes the organisation after reordering features when featurable is an organisation" do
    organisation = create(:organisation)
    feature_list = create(:feature_list, featurable: organisation, features: build_list(:feature, 6))

    # the organisation should only be republished once
    Whitehall::PublishingApi.expects(:republish_async).with(organisation).once

    feature_list.reorder! feature_list.features.pluck(:id).reverse
  end

  test "republishes the world location news after reordering features when featurable is a world location news" do
    world_location_news = build(:world_location_news)
    create(:world_location, world_location_news:)
    feature_list = create(:feature_list, featurable: world_location_news, features: build_list(:feature, 6))

    Whitehall::PublishingApi.expects(:republish_async).with(world_location_news).once

    feature_list.reorder! feature_list.features.pluck(:id).reverse
  end

  test "validation errors when reordering features are propogated" do
    feature1 = create(:feature)
    feature_list = create(:feature_list, locale: :en, features: [feature1])
    feature1.document = nil
    feature1.save!(validate: false)
    assert_not feature_list.reorder!([feature1.id])
    assert_match %r{Can't reorder because '.*'}, feature_list.errors.full_messages.to_sentence
  end

  test "reordering fails if features which are not part of the feature list are referenced when re-ordering" do
    feature1 = create(:feature)
    feature2 = create(:feature)
    feature3 = create(:feature)

    feature_list1 = create(:feature_list, locale: :en, features: [feature1, feature2])
    _feature_list2 = create(:feature_list, locale: :fr, features: [feature3])

    assert_not_nil f3_original_ordering = feature3.ordering

    assert_not feature_list1.reorder!([feature2.id, feature3.id, feature1.id])
    assert_match %r{Can't reorder because '.*'}, feature_list1.errors[:base].to_sentence

    assert_equal f3_original_ordering, feature3.reload.ordering
    assert_equal [feature1, feature2], feature_list1.reload.features
  end

  test "#features should still return featured documents after republication" do
    world_location = create(:world_location)

    _item_a = create(:published_speech, world_locations: [world_location])
    item_b = create(:published_speech, world_locations: [world_location])

    feature_list = create(:feature_list, featurable: world_location, locale: :en)
    create(:feature, feature_list:, document: item_b.document)

    editor = create(:departmental_editor)
    new_draft = item_b.create_draft(editor)
    new_draft.minor_change = true
    force_publish(new_draft)

    feature_list.reload

    assert_equal [new_draft.document], feature_list.features.map(&:document)
  end

  test "#published_features only returns features where there is a published edition" do
    published = create(:published_speech)
    draft = create(:draft_speech)

    feature_list = create(:feature_list, locale: :en)
    feature_list.features << build(:feature, document: published.document)
    feature_list.features << build(:feature, document: draft.document)

    assert_equal([[published], [draft]], feature_list.features.map { |f| f.document.editions })
    assert_equal([[published]], feature_list.published_features.map { |f| f.document.editions })
  end

  test "#published_features only excludes features which have ended" do
    published = create(:published_speech)

    feature_list = create(:feature_list, locale: :en)
    feature_list.features << build(:feature, document: published.document, ended_at: Time.zone.now)

    assert_equal([], feature_list.published_features.map { |f| f.document.editions })
  end

  test "#deep_clone clones the feature list, its features and their image data" do
    feature_list = create(:feature_list)
    create(:feature, :with_image, feature_list: feature_list, ordering: 1)
    create(:feature, :with_image, feature_list: feature_list, ordering: 2)

    cloned_feature_list = feature_list.deep_clone
    ignored_cols = %w[id created_at updated_at feature_list_id featured_imageable_id assetable_id]

    assert_equal feature_list.attributes.except(*ignored_cols),
                 cloned_feature_list.attributes.except(*ignored_cols)

    feature_list.features.zip(cloned_feature_list.features).each do |original, cloned|
      assert_not_equal original.id, cloned.id
      assert_equal original.attributes.except(*ignored_cols),
                   cloned.attributes.except(*ignored_cols)

      assert cloned.image.present?
      assert_not_equal original.image.id, cloned.image.id
      assert_equal original.image.attributes.except(*ignored_cols),
                   cloned.image.attributes.except(*ignored_cols)

      original.image.assets.zip(cloned.image.assets).each do |original_asset, cloned_asset|
        assert_not_equal original_asset.id, cloned_asset.id
        assert_equal original_asset.attributes.except(*ignored_cols),
                     cloned_asset.attributes.except(*ignored_cols)
      end
    end
  end
end
