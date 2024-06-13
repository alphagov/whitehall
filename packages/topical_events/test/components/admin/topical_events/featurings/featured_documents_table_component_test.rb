# frozen_string_literal: true

require "test_helper"

class Admin::TopicalEvents::Featurings::FeaturedDocumentsTableComponentTest < ViewComponent::TestCase
  include Rails.application.routes.url_helpers
  include Admin::EditionRoutesHelper

  test "renders the correct row when the featurable is associated with an edition" do
    edition = build_stubbed(:news_article, :published)
    topical_event = build_stubbed(:topical_event)
    featuring = build_stubbed(:topical_event_featuring, edition:, topical_event:)
    title = featuring.title

    render_inline(Admin::TopicalEvents::Featurings::FeaturedDocumentsTableComponent.new(
                    caption: "caption",
                    featurings: [featuring],
                  ))

    assert_equal page.all(".govuk-table .govuk-table__row .govuk-table__cell")[0].text, title
    assert_equal page.all(".govuk-table .govuk-table__row .govuk-table__cell")[1].text, "News Article (document)"
    assert_equal page.all(".govuk-table .govuk-table__row .govuk-table__cell")[2].text, I18n.localize(edition.major_change_published_at.to_date)

    actions_column = page.all(".govuk-table .govuk-table__row .govuk-table__cell")[3]
    actions_column.assert_selector "a[href='#{admin_edition_path(edition)}']", text: "View #{title}"
    actions_column.assert_selector "a[href='#{confirm_destroy_admin_topical_event_topical_event_featuring_path(topical_event, featuring)}']", text: "Unfeature #{title}"
  end

  test "renders the correct row when the featurable is associated with an offsite link" do
    topical_event = build_stubbed(:topical_event)
    featuring = build_stubbed(:offsite_topical_event_featuring, topical_event:)
    title = featuring.offsite_link.title

    render_inline(Admin::TopicalEvents::Featurings::FeaturedDocumentsTableComponent.new(
                    caption: "caption",
                    featurings: [featuring],
                  ))

    assert_equal page.all(".govuk-table .govuk-table__row .govuk-table__cell")[0].text, title
    assert_equal page.all(".govuk-table .govuk-table__row .govuk-table__cell")[1].text, "Alert (offsite link)"
    assert_equal page.all(".govuk-table .govuk-table__row .govuk-table__cell")[2].text, ""

    actions_column = page.all(".govuk-table .govuk-table__row .govuk-table__cell")[3]
    actions_column.assert_selector "a[href='#{polymorphic_path([:edit, :admin, topical_event, featuring.offsite_link])}']", text: "Edit #{title}"
    actions_column.assert_selector "a[href='#{confirm_destroy_admin_topical_event_topical_event_featuring_path(topical_event, featuring)}']", text: "Unfeature #{title}"
  end
end
