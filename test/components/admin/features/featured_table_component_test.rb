# frozen_string_literal: true

require "test_helper"

class Admin::Features::FeaturedDocumentsTableComponentTest < ViewComponent::TestCase
  include Rails.application.routes.url_helpers
  include Admin::EditionRoutesHelper
  include Admin::OrganisationHelper

  setup do
    @feature_list = build_stubbed(:feature_list)
  end

  test "renders the correct row when the feature list item belongs to a document with a live edition" do
    document = build(:document)
    edition = build_stubbed(:news_article, :published)
    document.stubs(:live_edition).returns(edition)
    feature = build_stubbed(:feature, document:, feature_list: @feature_list)
    title = edition.title

    render_inline(Admin::Features::FeaturedDocumentsTableComponent.new(caption: "caption", features: [feature]))

    assert_equal page.all(".govuk-table .govuk-table__row .govuk-table__cell")[0].text, title
    assert_equal page.all(".govuk-table .govuk-table__row .govuk-table__cell")[1].text, "News Article (document)"
    assert_equal page.all(".govuk-table .govuk-table__row .govuk-table__cell")[2].text, I18n.localize(edition.major_change_published_at.to_date)

    actions_column = page.all(".govuk-table .govuk-table__row .govuk-table__cell")[3]
    actions_column.assert_selector "a[href='#{admin_edition_path(edition)}']", text: "Edit #{title}"
    actions_column.assert_selector "a[href='#{confirm_unfeature_admin_feature_list_feature_path(@feature_list, feature)}']", text: "Unfeature #{title}"
  end

  test "renders the correct row when the feature list item belongs to a topical event" do
    feature = build_stubbed(:feature, :with_topical_event_association, feature_list: @feature_list)
    title = feature.topical_event.name

    render_inline(Admin::Features::FeaturedDocumentsTableComponent.new(caption: "caption", features: [feature]))

    assert_equal page.all(".govuk-table .govuk-table__row .govuk-table__cell")[0].text, title
    assert_equal page.all(".govuk-table .govuk-table__row .govuk-table__cell")[1].text, "Topical Event"
    assert_equal page.all(".govuk-table .govuk-table__row .govuk-table__cell")[2].text, topical_event_dates_string(feature.topical_event)

    actions_column = page.all(".govuk-table .govuk-table__row .govuk-table__cell")[3]
    actions_column.assert_selector "a[href='#{edit_admin_topical_event_path(feature.topical_event)}']", text: "Edit #{title}"
    actions_column.assert_selector "a[href='#{confirm_unfeature_admin_feature_list_feature_path(feature.feature_list, feature)}']", text: "Unfeature #{title}"
  end

  test "renders the correct row when the feature list item belongs to a offsite link" do
    feature = build_stubbed(:feature, :with_offsite_link_association, feature_list: @feature_list)
    title = feature.offsite_link.title

    render_inline(Admin::Features::FeaturedDocumentsTableComponent.new(caption: "caption", features: [feature]))

    assert_equal page.all(".govuk-table .govuk-table__row .govuk-table__cell")[0].text, title
    assert_equal page.all(".govuk-table .govuk-table__row .govuk-table__cell")[1].text, "Alert (offsite link)"
    assert_equal page.all(".govuk-table .govuk-table__row .govuk-table__cell")[2].text, ""

    actions_column = page.all(".govuk-table .govuk-table__row .govuk-table__cell")[3]
    actions_column.assert_selector "a[href='#{polymorphic_path([:edit, :admin, feature.offsite_link.parent, feature.offsite_link])}']", text: "Edit #{title}"
    actions_column.assert_selector "a[href='#{confirm_unfeature_admin_feature_list_feature_path(feature.feature_list, feature)}']", text: "Unfeature #{title}"
  end

  test "renders the correct row when the feature list item does not have an association" do
    feature = build_stubbed(:feature, document: nil)

    render_inline(Admin::Features::FeaturedDocumentsTableComponent.new(caption: "caption", features: [feature]))

    assert_equal page.all(".govuk-table .govuk-table__row .govuk-table__cell")[0].text, "Feature #{feature.id}"
    assert_equal page.all(".govuk-table .govuk-table__row .govuk-table__cell")[1].text, ""
    assert_equal page.all(".govuk-table .govuk-table__row .govuk-table__cell")[2].text, ""
    assert_equal page.all(".govuk-table .govuk-table__row .govuk-table__cell")[3].text, ""
  end
end
