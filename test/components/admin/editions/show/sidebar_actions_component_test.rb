# frozen_string_literal: true

require "test_helper"

class Admin::Editions::Show::SidebarActionsComponentTest < ViewComponent::TestCase
  test "actions for draft edition" do
    current_user = build_stubbed(:user)
    edition = create(:draft_edition)
    render_inline(Admin::Editions::Show::SidebarActionsComponent.new(edition:, current_user:))

    assert_selector "li", count: 3
    assert_selector "button", text: "Submit for 2nd eyes"
    assert_selector "a", text: "Edit draft"
    assert_selector "a", text: "Delete draft"
  end

  test "actions for published edition" do
    current_user = build_stubbed(:user)
    edition = create(:published_edition)
    render_inline(Admin::Editions::Show::SidebarActionsComponent.new(edition:, current_user:))

    assert_selector "li", count: 5
    assert_selector "button", text: "Create new edition"
    assert_selector "a", text: "View published edition"
    assert_selector "a", text: "Set review date"
    assert_selector "a", text: "View data about page"
    assert_selector "a[href='https://www.test.gov.uk/government/generic-editions/#{edition.title}']", text: "View on website (opens in new tab)"
  end

  test "actions for published edition with review date" do
    current_user = build_stubbed(:user)
    edition = create(:published_edition)
    create(:review_reminder, :reminder_due, document: edition.document)
    render_inline(Admin::Editions::Show::SidebarActionsComponent.new(edition:, current_user:))

    assert_selector "li", count: 6
    assert_selector "button", text: "Create new edition"
    assert_selector "a", text: "View published edition"
    assert_selector "a", text: "Edit review date"
    assert_selector "a", text: "Delete review date"
    assert_selector "a", text: "View data about page"
    assert_selector "a[href='https://www.test.gov.uk/government/generic-editions/#{edition.title}']", text: "View on website (opens in new tab)"
  end

  test "actions for published edition for non-english document" do
    current_user = build_stubbed(:user)
    edition = create(:non_english_published_edition)
    render_inline(Admin::Editions::Show::SidebarActionsComponent.new(edition:, current_user:))

    assert_selector "li", count: 5
    assert_selector "button", text: "Create new edition"
    assert_selector "a", text: "View published edition"
    assert_selector "a", text: "Set review date"
    assert_selector "a", text: "View data about page"
    assert_selector "a[href='https://www.test.gov.uk/government/generic-editions/#{edition.document.id}.cy']", text: "View on website (opens in new tab)"
  end

  test "actions for submitted edition" do
    current_user = build_stubbed(:user)
    edition = create(:submitted_edition)
    render_inline(Admin::Editions::Show::SidebarActionsComponent.new(edition:, current_user:))

    assert_selector "li", count: 2
    assert_selector "a", text: "Edit draft"
    assert_selector "a", text: "Delete draft"
  end

  test "actions for rejected edition" do
    current_user = build_stubbed(:user)
    edition = create(:rejected_edition)
    render_inline(Admin::Editions::Show::SidebarActionsComponent.new(edition:, current_user:))

    assert_selector "li", count: 3
    assert_selector "a", text: "Edit draft"
    assert_selector "a", text: "Delete draft"
    assert_selector "button", text: "Submit for 2nd eyes"
  end

  test "actions for superseded edition" do
    current_user = build_stubbed(:user)
    edition = create(:superseded_edition)
    render_inline(Admin::Editions::Show::SidebarActionsComponent.new(edition:, current_user:))

    assert_no_selector "app-view-summary__sidebar-actions"
  end

  test "actions for scheduled edition" do
    current_user = build_stubbed(:user)
    edition = create(:scheduled_edition)
    render_inline(Admin::Editions::Show::SidebarActionsComponent.new(edition:, current_user:))

    assert_selector "li", count: 2
    assert_selector "a", text: "Unschedule"
    assert_selector "a", text: "View scheduled edition"
  end

  test "actions for unpublished edition" do
    current_user = build_stubbed(:user)
    edition = create(:unpublished_edition)
    render_inline(Admin::Editions::Show::SidebarActionsComponent.new(edition:, current_user:))

    assert_selector "li", count: 2
    assert_selector "button", text: "Create new edition"
    assert_selector "a", text: "View unpublished edition"
  end

  test "actions for withdrawn edition" do
    current_user = build_stubbed(:user)
    edition = create(:withdrawn_edition)
    render_inline(Admin::Editions::Show::SidebarActionsComponent.new(edition:, current_user:))

    assert_selector "li", count: 4
    assert_selector "a", text: "Set review date"
    assert_selector "a", text: "View withdrawn edition"
    assert_selector "a", text: "View data about page"
    assert_selector "a", text: "View on website (opens in new tab)"
  end

  test "actions for draft edition as managing editor" do
    current_user = build_stubbed(:managing_editor)
    edition = create(:draft_edition)
    render_inline(Admin::Editions::Show::SidebarActionsComponent.new(edition:, current_user:))

    assert_selector "li", count: 4
    assert_selector "button", text: "Submit for 2nd eyes"
    assert_selector "a", text: "Force publish"
    assert_selector "a", text: "Edit draft"
    assert_selector "a", text: "Delete draft"
  end

  test "actions for draft edition with a scheduled date as managing editor" do
    current_user = build_stubbed(:managing_editor)
    edition = create(:draft_edition, scheduled_publication: 1.day.from_now)
    render_inline(Admin::Editions::Show::SidebarActionsComponent.new(edition:, current_user:))

    assert_selector "li", count: 4
    assert_selector "button", text: "Submit for 2nd eyes"
    assert_selector "a", text: "Force schedule"
    assert_selector "a", text: "Edit draft"
    assert_selector "a", text: "Delete draft"
  end

  test "actions for published edition as managing editor" do
    current_user = build_stubbed(:managing_editor)
    edition = create(:published_edition)
    render_inline(Admin::Editions::Show::SidebarActionsComponent.new(edition:, current_user:))

    assert_selector "li", count: 6
    assert_selector "button", text: "Create new edition"
    assert_selector "a", text: "View published edition"
    assert_selector "a", text: "Set review date"
    assert_selector "a", text: "Withdraw or unpublish"
    assert_selector "a", text: "View data about page"
    assert_selector "a", text: "View on website (opens in new tab)"
  end

  test "actions for submitted edition as managing editor" do
    current_user = build_stubbed(:managing_editor)
    edition = create(:submitted_edition)
    render_inline(Admin::Editions::Show::SidebarActionsComponent.new(edition:, current_user:))

    assert_selector "li", count: 4
    assert_selector "a", text: "Publish"
    assert_selector "button", text: "Reject"
    assert_selector "a", text: "Edit draft"
    assert_selector "a", text: "Delete draft"
  end

  test "actions for submitted edition with a scheduled date as managing editor" do
    current_user = build_stubbed(:managing_editor)
    edition = create(:submitted_edition, scheduled_publication: 1.day.from_now)
    render_inline(Admin::Editions::Show::SidebarActionsComponent.new(edition:, current_user:))

    assert_selector "li", count: 4
    assert_selector "button", text: "Schedule"
    assert_selector "button", text: "Reject"
    assert_selector "a", text: "Edit draft"
    assert_selector "a", text: "Delete draft"
  end

  test "actions for rejected edition as managing editor" do
    current_user = build_stubbed(:managing_editor)
    edition = create(:rejected_edition)
    render_inline(Admin::Editions::Show::SidebarActionsComponent.new(edition:, current_user:))

    assert_selector "li", count: 3
    assert_selector "a", text: "Edit draft"
    assert_selector "a", text: "Delete draft"
    assert_selector "button", text: "Submit for 2nd eyes"
  end

  test "actions for superseded edition as managing editor" do
    current_user = build_stubbed(:managing_editor)
    edition = create(:superseded_edition)
    render_inline(Admin::Editions::Show::SidebarActionsComponent.new(edition:, current_user:))

    assert_no_selector "app-view-summary__sidebar-actions"
  end

  test "actions for scheduled edition as managing editor" do
    current_user = build_stubbed(:managing_editor)
    edition = create(:scheduled_edition)
    render_inline(Admin::Editions::Show::SidebarActionsComponent.new(edition:, current_user:))

    assert_selector "li", count: 2
    assert_selector "a", text: "Unschedule"
    assert_selector "a", text: "View scheduled edition"
  end

  test "actions for unpublished edition as managing editor" do
    current_user = build_stubbed(:managing_editor)
    edition = create(:edition, :published_in_error_no_redirect)
    render_inline(Admin::Editions::Show::SidebarActionsComponent.new(edition:, current_user:))

    assert_selector "li", count: 3
    assert_selector "button", text: "Create new edition"
    assert_selector "a", text: "View unpublished edition"
    assert_selector "a", text: "Edit unpublishing information"
  end

  test "actions for withdrawn edition as managing editor" do
    current_user = build_stubbed(:managing_editor)
    edition = create(:withdrawn_edition)
    render_inline(Admin::Editions::Show::SidebarActionsComponent.new(edition:, current_user:))

    assert_selector "li", count: 6
    assert_selector "a", text: "Unwithdraw"
    assert_selector "a", text: "View withdrawn edition"
    assert_selector "a", text: "Edit withdrawal information"
    assert_selector "a", text: "Set review date"
    assert_selector "a", text: "View data about page"
    assert_selector "a", text: "View on website (opens in new tab)"
  end
end
