# frozen_string_literal: true

require "test_helper"

class Admin::Editions::Show::PreviewComponentTest < ViewComponent::TestCase
  setup do
    @document = build(:document)
  end

  test "does not render if edition is publically visible" do
    edition = build(:published_edition)
    render_inline(Admin::Editions::Show::PreviewComponent.new(edition:))

    assert page.text.blank?
  end

  test "does not render if edition is unpublished" do
    edition = build(:unpublished_edition)
    render_inline(Admin::Editions::Show::PreviewComponent.new(edition:))

    assert page.text.blank?
  end

  test "renders a link with tracking to preview the document when the edition is english only" do
    edition = build_stubbed(:publication, document: @document)

    render_inline(Admin::Editions::Show::PreviewComponent.new(edition:))
    page.find("a[href='#{edition.public_url(draft: true)}']", text: "Preview on website (opens in new tab)")
  end

  test "renders a link with tracking to preview the document when the edition is a foreign language only edition" do
    edition = build_stubbed(:publication, document: @document, primary_locale: :fr)

    render_inline(Admin::Editions::Show::PreviewComponent.new(edition:))
    page.find("a[href='#{edition.public_url(draft: true)}']", text: "Preview on website (opens in new tab)")
  end

  test "renders a link with tracking to preview the document for each translation when there are multiple translations" do
    edition = create(:publication, translated_into: %i[fr es], document: @document)

    render_inline(Admin::Editions::Show::PreviewComponent.new(edition:))
    page.find("a[href='#{edition.public_url(draft: true)}']", text: "Preview on website - English (opens in new tab)")
    page.find("a[href='#{edition.public_url(locale: 'fr', draft: true)}']", visible: false, text: "Preview on website - Français (French) (opens in new tab)")
    page.find("a[href='#{edition.public_url(locale: 'es', draft: true)}']", visible: false, text: "Preview on website - Español (Spanish) (opens in new tab)")
  end

  test "renders sharable preview functionality when edition is a pre-publication state" do
    edition = build_stubbed(:publication, document: @document)

    render_inline(Admin::Editions::Show::PreviewComponent.new(edition:))

    assert_selector ".govuk-details__summary-text", text: "Share document preview"
  end

  test "does not render sharable preview functionality when edition is in a post-published state" do
    edition = build(:published_publication, document: @document)

    render_inline(Admin::Editions::Show::PreviewComponent.new(edition:))

    assert_selector ".govuk-details__summary-text", text: "Share document preview", count: 0
  end

  test "does not render preview or sharable preview functionality and informs the user when versioning needs to be completed" do
    edition = build(:publication, document: @document)
    edition.stubs(:versioning_completed?).returns(false)

    render_inline(Admin::Editions::Show::PreviewComponent.new(edition:))

    assert_selector "a[href='#{edition.public_url(draft: true)}']", text: "Preview on website (opens in new tab)", count: 0
    assert_selector ".govuk-details__summary-text", text: "Share document preview", count: 0
    assert_selector ".govuk-inset-text", text: "To see the changes and share a document preview link, add a change note or mark the change type to minor."
  end
end
