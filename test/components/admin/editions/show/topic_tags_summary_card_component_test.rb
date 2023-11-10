# frozen_string_literal: true

require "test_helper"
class Admin::Editions::Show::TopicTagsSummaryCardComponentTest < ViewComponent::TestCase
  include Rails.application.routes.url_helpers

  test "it renders a summary card with the title 'Topic taxonomy tags'" do
    edition = build_stubbed(:edition)

    render_inline(Admin::Editions::Show::TopicTagsSummaryCardComponent.new(edition:, edition_taxons: []))

    assert_selector ".govuk-summary-card__title", text: "Topic taxonomy tags"
  end

  test "it renders a summary card with a link for managing the tags" do
    edition = build_stubbed(:edition)

    render_inline(Admin::Editions::Show::TopicTagsSummaryCardComponent.new(edition:, edition_taxons: []))

    assert_selector ".govuk-summary-card__action a[href=\"#{edit_admin_edition_tags_path(edition.id)}\"]", text: "Manage tags"
  end

  test "it renders a warning when there are no edition taxons" do
    edition = build_stubbed(:edition)

    render_inline(Admin::Editions::Show::TopicTagsSummaryCardComponent.new(edition:, edition_taxons: []))

    assert_selector ".govuk-warning-text__text", text: "You need to add topic tags before you can publish this document."
  end

  test "it does not render a warning when there are edition taxons present" do
    edition = build_stubbed(:edition)
    taxons = build_list(:taxon_hash, 3).map { |taxon_hash| Taxonomy::Taxon.from_taxon_hash(taxon_hash) }

    render_inline(Admin::Editions::Show::TopicTagsSummaryCardComponent.new(edition:, edition_taxons: taxons))

    assert_selector ".govuk-warning-text__text", count: 0
  end

  test "it renders a breadcrumb for each edition taxon" do
    edition = build_stubbed(:edition)
    taxons = build_list(:taxon_hash, 3).map { |taxon_hash| Taxonomy::Taxon.from_taxon_hash(taxon_hash) }

    render_inline(Admin::Editions::Show::TopicTagsSummaryCardComponent.new(edition:, edition_taxons: taxons))

    taxons.each do |taxon|
      taxon.full_path.each do |tag_path_segment|
        assert_selector ".govuk-breadcrumbs__list-item", text: tag_path_segment[:title]
      end
    end
  end
end
