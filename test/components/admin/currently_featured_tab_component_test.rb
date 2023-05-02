# frozen_string_literal: true

require "test_helper"

class Admin::CurrentlyFeaturedTabComponentTest < ViewComponent::TestCase
  include Rails.application.routes.url_helpers
  include Admin::EditionRoutesHelper
  include Admin::OrganisationHelper

  setup do
    @maximum_featured_documents = 5
  end

  test "renders h2 so that screen readers have context for which tab they're in" do
    render_inline(Admin::CurrentlyFeaturedTabComponent.new(
                    features: [],
                    maximum_featured_documents: @maximum_featured_documents,
                  ))

    assert_selector "h2", text: "Currently featured"
  end

  test "informs the user how many documents they can feature" do
    render_inline(Admin::CurrentlyFeaturedTabComponent.new(
                    features: [],
                    maximum_featured_documents: @maximum_featured_documents,
                  ))

    assert_selector ".gem-c-inset-text", text: "A maximum of 5 documents will be featured on GOV.UK."
  end

  test "renders link to the reorder page if more than 1 feature_list item" do
    render_inline(Admin::CurrentlyFeaturedTabComponent.new(
                    features: build_list(:feature, 2),
                    maximum_featured_documents: @maximum_featured_documents,
                  ))

    assert_selector ".govuk-link", text: "Reorder documents" do |link|
      # this will be updated when i add the reorder endpoint
      assert link[:href] == "#"
    end
  end

  test "does not render link to the reorder page if less than 2 feature_list items" do
    render_inline(Admin::CurrentlyFeaturedTabComponent.new(
                    features: [build(:feature)],
                    maximum_featured_documents: @maximum_featured_documents,
                  ))

    assert_selector ".govuk-link", text: "reorder", count: 0
  end

  test "Only renders the live featured documents table when feature_list count is <= to maximum_featured_documents" do
    render_inline(Admin::CurrentlyFeaturedTabComponent.new(
                    features: build_list(:feature, @maximum_featured_documents),
                    maximum_featured_documents: @maximum_featured_documents,
                  ))

    assert_selector ".govuk-table", count: 1
    assert_selector ".govuk-table__caption", text: "#{@maximum_featured_documents} featured documents live on GOV.UK"
  end

  test "renders the live featured documents table and the remaining documents table when feature_list count is great than maximum_featured_documents" do
    render_inline(Admin::CurrentlyFeaturedTabComponent.new(
                    features: build_list(:feature, @maximum_featured_documents + 1),
                    maximum_featured_documents: @maximum_featured_documents,
                  ))

    assert_selector ".govuk-table", count: 2
    assert_selector ".govuk-table__caption", text: "#{@maximum_featured_documents} featured documents live on GOV.UK"
    assert_selector ".govuk-table__caption", text: "1 remaining featured document"
  end

  test "renders the correct row when the feature list item belongs to a document with a live edition" do
    document = build(:document)
    edition = build_stubbed(:news_article, :published)
    document.stubs(:live_edition).returns(edition)
    title = edition.title

    render_inline(Admin::CurrentlyFeaturedTabComponent.new(
                    features: [build(:feature, document:)],
                    maximum_featured_documents: @maximum_featured_documents,
                  ))

    assert_equal page.all(".govuk-table .govuk-table__row .govuk-table__cell")[0].text, title
    assert_equal page.all(".govuk-table .govuk-table__row .govuk-table__cell")[1].text, "News Article (document)"
    assert_equal page.all(".govuk-table .govuk-table__row .govuk-table__cell")[2].text, I18n.localize(edition.major_change_published_at.to_date)

    actions_column = page.all(".govuk-table .govuk-table__row .govuk-table__cell")[3]
    actions_column.assert_selector "a[href='#{admin_edition_path(edition)}']", text: "Edit #{title}"
    # this will be updated when i add the unfeatued endpoint
    actions_column.assert_selector "a[href='#']", text: "Unfeature #{title}"
  end

  test "renders the correct row when the feature list item belongs to a topical event" do
    feature = build_stubbed(:feature, :with_topical_event_association)
    title = feature.topical_event.name

    render_inline(Admin::CurrentlyFeaturedTabComponent.new(
                    features: [feature],
                    maximum_featured_documents: @maximum_featured_documents,
                  ))

    assert_equal page.all(".govuk-table .govuk-table__row .govuk-table__cell")[0].text, title
    assert_equal page.all(".govuk-table .govuk-table__row .govuk-table__cell")[1].text, "Topical Event"
    assert_equal page.all(".govuk-table .govuk-table__row .govuk-table__cell")[2].text, topical_event_dates_string(feature.topical_event)

    actions_column = page.all(".govuk-table .govuk-table__row .govuk-table__cell")[3]
    actions_column.assert_selector "a[href='#{edit_admin_topical_event_path(feature.topical_event)}']", text: "Edit #{title}"
    # this will be updated when i add the unfeatued endpoint
    actions_column.assert_selector "a[href='#']", text: "Unfeature #{title}"
  end

  test "renders the correct row when the feature list item belongs to a offsite link" do
    feature = build_stubbed(:feature, :with_offsite_link_association)
    title = feature.offsite_link.title

    render_inline(Admin::CurrentlyFeaturedTabComponent.new(
                    features: [feature],
                    maximum_featured_documents: @maximum_featured_documents,
                  ))

    assert_equal page.all(".govuk-table .govuk-table__row .govuk-table__cell")[0].text, title
    assert_equal page.all(".govuk-table .govuk-table__row .govuk-table__cell")[1].text, "Alert (offsite link)"
    assert_equal page.all(".govuk-table .govuk-table__row .govuk-table__cell")[2].text, ""

    actions_column = page.all(".govuk-table .govuk-table__row .govuk-table__cell")[3]
    actions_column.assert_selector "a[href='#{polymorphic_path([:edit, :admin, feature.offsite_link.parent, feature.offsite_link])}']", text: "Edit #{title}"
    # this will be updated when i add the unfeatued endpoint
    actions_column.assert_selector "a[href='#']", text: "Unfeature #{title}"
  end

  test "renders the correct row when the feature list item does not have an association" do
    feature = build_stubbed(:feature, document: nil)

    render_inline(Admin::CurrentlyFeaturedTabComponent.new(
                    features: [feature],
                    maximum_featured_documents: @maximum_featured_documents,
                  ))

    assert_equal page.all(".govuk-table .govuk-table__row .govuk-table__cell")[0].text, "Feature #{feature.id}"
    assert_equal page.all(".govuk-table .govuk-table__row .govuk-table__cell")[1].text, ""
    assert_equal page.all(".govuk-table .govuk-table__row .govuk-table__cell")[2].text, ""
    assert_equal page.all(".govuk-table .govuk-table__row .govuk-table__cell")[3].text, ""
  end
end
