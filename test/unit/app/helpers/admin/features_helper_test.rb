require "test_helper"

class Admin::FeaturesHelperTest < ActionView::TestCase
  setup do
    topical_event_type = build_configurable_document_type("topical_event", { "settings" => { "features_enabled" => true } })
    test_type_with_topical_event_association = build_configurable_document_type("test_type", { "associations" => [
      {
        "key" => "topical_event_documents",
      },
    ] })
    ConfigurableDocumentType.setup_test_types(topical_event_type.merge(test_type_with_topical_event_association))
  end

  test "#featurable_editions_for_feature_list filters out any edition in the feature list" do
    edition = create(
      :published_standard_edition,
      :with_organisations,
      configurable_document_type: "topical_event",
    )

    featured_edition_1 = create(:published_standard_edition, :with_organisations, title: "Edition 1")
    featured_edition_2 = create(:published_standard_edition, :with_organisations, title: "Edition 2")
    unfeatured_edition = create(:published_standard_edition, :with_organisations, title: "Edition 3")
    feature_list = edition.feature_lists.create!(locale: edition.primary_locale)

    create(:feature, feature_list:, document: featured_edition_1.document)
    create(:feature, feature_list:, document: featured_edition_2.document)

    featurable_editions_for_feature_list = featurable_editions_for_feature_list([featured_edition_1, featured_edition_2, unfeatured_edition], feature_list)

    assert_equal [unfeatured_edition], featurable_editions_for_feature_list
  end

  test "#featurable_editions_for_feature_list returns a list of editions for the specified locale" do
    edition = create(
      :published_standard_edition,
      :with_organisations,
      :translated,
      primary_locale: :en,
      translated_into: %w[cy],
      configurable_document_type: "topical_event",
    )

    unfeatured_edition = create(:published_standard_edition,
                                :with_organisations,
                                :with_organisations,
                                :translated,
                                primary_locale: :en,
                                translated_into: %w[cy],
                                title: "Unfeatured edition")
    feature_list = edition.feature_lists.create!(locale: :cy)
    featurable_editions_for_feature_list = featurable_editions_for_feature_list([unfeatured_edition], feature_list)

    assert_equal with_locale(:cy) { unfeatured_edition.title }, featurable_editions_for_feature_list.first.title
  end
end
