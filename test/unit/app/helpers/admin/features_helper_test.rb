require "test_helper"

class Admin::FeaturesHelperTest < ActionView::TestCase
  test "#featurable_editions_for_feature_list filters out any edition in the feature list" do
    organisation = create(:organisation)

    featured_edition_1 = create(:published_standard_edition, :with_organisations, title: "Edition 1")
    featured_edition_2 = create(:published_standard_edition, :with_organisations, title: "Edition 2")
    unfeatured_edition = create(:published_standard_edition, :with_organisations, title: "Edition 3")
    feature_list = organisation.feature_lists.create!(locale: :en)

    create(:feature, feature_list:, document: featured_edition_1.document)
    create(:feature, feature_list:, document: featured_edition_2.document)

    featurable_editions_for_feature_list = featurable_editions_for_feature_list([featured_edition_1, featured_edition_2, unfeatured_edition], feature_list)

    assert_equal [unfeatured_edition], featurable_editions_for_feature_list
  end

  test "#featurable_editions_for_feature_list returns a list of editions for the specified locale" do
    organisation = create(:organisation, translated_into: %i[de])

    unfeatured_edition = create(:published_standard_edition,
                                :with_organisations,
                                :translated,
                                primary_locale: :en,
                                translated_into: %w[de],
                                title: "Unfeatured edition")
    feature_list = organisation.feature_lists.create!(locale: :de)
    featurable_editions_for_feature_list = featurable_editions_for_feature_list([unfeatured_edition], feature_list)

    assert_equal with_locale(:de) { unfeatured_edition.title }, featurable_editions_for_feature_list.first.title
  end
end
