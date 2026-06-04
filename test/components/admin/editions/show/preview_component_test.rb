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

    travel_to(Time.zone.local(2026, 5, 27, 12, 0, 0)) do
      render_inline(Admin::Editions::Show::PreviewComponent.new(edition:))
      cachebust = Time.zone.now.getutc.to_i
      assert_selector "a[href='#{edition.public_url(draft: true, cachebust:)}']", text: "Preview on website (opens in new tab)"
    end
  end

  test "renders a link with tracking to preview the document when the edition is a foreign language only edition" do
    edition = build_stubbed(:publication, document: @document, primary_locale: :fr)

    travel_to(Time.zone.local(2026, 5, 27, 12, 0, 0)) do
      render_inline(Admin::Editions::Show::PreviewComponent.new(edition:))
      cachebust = Time.zone.now.getutc.to_i
      assert_selector "a[href='#{edition.public_url(draft: true, cachebust:)}']", text: "Preview on website (opens in new tab)"
    end
  end

  test "renders a link with tracking to preview the document for each translation when there are multiple translations" do
    edition = create(:publication, translated_into: %i[fr es], document: @document)

    travel_to(Time.zone.local(2026, 5, 27, 12, 0, 0)) do
      render_inline(Admin::Editions::Show::PreviewComponent.new(edition:))
      cachebust = Time.zone.now.getutc.to_i
      assert_selector "a[href='#{edition.public_url(draft: true, cachebust:)}']", text: "Preview on website - English (opens in new tab)"
      assert_selector "a[href='#{edition.public_url(locale: 'fr', draft: true, cachebust:)}']", visible: false, text: "Preview on website - French (Français) (opens in new tab)"
      assert_selector "a[href='#{edition.public_url(locale: 'es', draft: true, cachebust:)}']", visible: false, text: "Preview on website - Spanish (Español) (opens in new tab)"
    end
  end

  test "renders sharable preview functionality when edition is a pre-publication state" do
    edition = build_stubbed(:publication, document: @document)

    render_inline(Admin::Editions::Show::PreviewComponent.new(edition:))

    assert_selector ".govuk-details__summary-text", text: "Share preview link with someone else"
  end

  test "renders the copy link, regenerate and delete controls when the edition has a preview token" do
    edition = build_stubbed(:publication, document: @document)

    render_inline(Admin::Editions::Show::PreviewComponent.new(edition:))

    assert_text "Anyone with a link can preview the content on GOV.UK."
    assert_text "The link will expire on"
    assert_text "The old link will no longer work."
    assert_button "Copy link", exact: true, visible: :all
    assert_button "Generate new link", exact: true, visible: :all
    assert_button "Delete link", exact: true, visible: :all
  end

  test "renders only a generate control and no link when the edition has no preview token" do
    edition = build_stubbed(:publication, document: @document, auth_bypass_id: nil)

    render_inline(Admin::Editions::Show::PreviewComponent.new(edition:))

    assert_text "Anyone with a link can preview the content on GOV.UK."
    assert_button "Generate link", exact: true, visible: :all
    assert_no_button "Copy link", exact: true, visible: :all
    assert_no_button "Delete link", exact: true, visible: :all
  end

  test "does not render sharable preview functionality when edition is in a post-published state" do
    edition = build(:published_publication, document: @document)

    render_inline(Admin::Editions::Show::PreviewComponent.new(edition:))

    assert_selector ".govuk-details__summary-text", text: "Share preview link with someone else", count: 0
  end

  test "does not render preview or sharable preview functionality and informs the user when versioning needs to be completed" do
    edition = build(:publication, document: @document)
    edition.stubs(:versioning_completed?).returns(false)

    render_inline(Admin::Editions::Show::PreviewComponent.new(edition:))

    assert_selector "a[href='#{edition.public_url(draft: true)}']", text: "Preview on website (opens in new tab)", count: 0
    assert_selector ".govuk-details__summary-text", text: "Share preview link with someone else", count: 0
    assert_selector ".govuk-inset-text", text: "To see the changes and share a document preview link, add a change note or mark the change type to minor."
  end

  test "tags every preview link with the CachebustLink JS module" do
    edition = create(:publication, translated_into: %i[fr], document: @document)

    render_inline(Admin::Editions::Show::PreviewComponent.new(edition:))

    assert_selector "a[data-module='CachebustLink'][href*='cachebust=']", visible: :all, count: 2
  end

  test "renders the correct primary locale link text for non-English primary locale editions with translations" do
    edition = build(:detailed_guide, id: 1, primary_locale: :fr, document: @document)
    edition.translations.build(locale: :fr)
    edition.translations.build(locale: :de)

    render_inline(Admin::Editions::Show::PreviewComponent.new(edition:))

    assert page.has_content? "Preview on website - French (opens in new tab)"
  end

  test "does not render the primary locale preview link twice" do
    edition = build(:detailed_guide, id: 1, primary_locale: :fr, document: @document)
    edition.translations.build(locale: :fr)
    edition.translations.build(locale: :de)

    render_inline(Admin::Editions::Show::PreviewComponent.new(edition:))

    assert page.has_content? "Preview on website - French (opens in new tab)"
    assert_not page.has_content? "Preview on website - Français (French) (opens in new tab)"
  end
end
