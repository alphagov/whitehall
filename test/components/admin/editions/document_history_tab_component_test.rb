# frozen_string_literal: true

require "test_helper"

class Admin::Editions::DocumentHistoryTabComponentTest < ViewComponent::TestCase
  include Rails.application.routes.url_helpers

  setup do
    @user = create(:departmental_editor)
    @user2 = create(:departmental_editor)
    seed_document_event_history
    @timeline = Document::PaginatedTimeline.new(document: @document, page: 1)

    pagination = "<nav class='govuk-grid-row govuk-!-margin-bottom-4' role='navigation'>
                    <a class='govuk-body govuk-link app-view-document-history-tab__pagination-link' data-remote-pagination='/government/admin/editions/1321865/audit_trail?page=2' rel='next' href='/government/admin/consultations/1321865?page=2'>Older</a>
                   </nav>".html_safe

    Admin::Editions::DocumentHistoryTabComponent.any_instance.stubs(:paginate).returns(pagination)
  end

  test "it renders a link to the add remark page" do
    render_inline(Admin::Editions::DocumentHistoryTabComponent.new(edition: @first_edition, document_history: @timeline))

    assert_equal page.all("a")[0].text, "Add internal note"
    assert_equal page.all("a")[0][:href], new_admin_edition_editorial_remark_path(@first_edition)
  end

  test "it renders content telling a user to save changes when editing is `true`" do
    render_inline(Admin::Editions::DocumentHistoryTabComponent.new(edition: @first_edition, document_history: @timeline, editing: true))

    assert_selector "p", text: "To add an internal note, save your changes."
  end

  test "it renders a inset component which links to the whats new page" do
    render_inline(Admin::Editions::DocumentHistoryTabComponent.new(edition: @first_edition, document_history: @timeline))

    assert_selector ".gem-c-inset-text", text: "History and notes have been merged. Read more about the change"
    assert_equal page.all(".gem-c-inset-text a")[0].text, "Read more about the change"
    assert_equal page.all(".gem-c-inset-text a")[0][:href], admin_whats_new_path
  end

  test "it renders pagination links based on the pagination attribute" do
    render_inline(Admin::Editions::DocumentHistoryTabComponent.new(edition: @first_edition, document_history: @timeline))

    assert_selector ".app-view-document-history-tab__pagination-link", text: "Older"
  end

  test "it renders the timeline entries in the correct sections for, future, current and previous editions" do
    render_inline(Admin::Editions::DocumentHistoryTabComponent.new(edition: @second_edition, document_history: @timeline))

    assert_selector ".app-view-editions__newer-edition-entries h3", text: "On newer editions"
    assert_selector ".app-view-editions__newer-edition-entries li.app-view-editions-audit-trail-entry__list-item", count: 2
    assert_selector ".app-view-editions__newer-edition-entries li.app-view-editions-editorial-remark__list-item", count: 1

    assert_selector ".app-view-editions__current-edition-entries h3", text: "On this edition"
    assert_selector ".app-view-editions__current-edition-entries li.app-view-editions-audit-trail-entry__list-item", count: 4
    assert_selector ".app-view-editions__current-edition-entries li.app-view-editions-editorial-remark__list-item", count: 1

    assert_selector ".app-view-editions__previous-edition-entries h3", text: "On previous editions"
    assert_selector ".app-view-editions__previous-edition-entries li.app-view-editions-audit-trail-entry__list-item", count: 2
    assert_selector ".app-view-editions__previous-edition-entries li.app-view-editions-editorial-remark__list-item", count: 0
  end

  def seed_document_event_history
    acting_as(@user) do
      @document = create(:document)
      @first_edition = create(:draft_edition, document: @document, major_change_published_at: Time.zone.now)
      some_time_passes
      @first_edition.submit!
    end

    some_time_passes

    acting_as(@user2) do
      create(:editorial_remark, edition: @first_edition, author: @user2, body: "This is terrible. Make it better!")
      some_time_passes
      @first_edition.reject!
    end

    some_time_passes

    acting_as(@user) do
      @first_edition.update!(body: "New and improved")
      some_time_passes
      create(:editorial_remark, edition: @first_edition, author: @user, body: "I've made it better.")
      some_time_passes
      @first_edition.submit!
    end

    some_time_passes

    acting_as(@user2) do
      @first_edition.publish!
    end

    some_time_passes

    acting_as(@user) do
      @second_edition = create(:draft_edition, document: @document, major_change_published_at: Time.zone.now)
      some_time_passes
      @second_edition.update!(body: "New draft changes")
      some_time_passes
      create(:editorial_remark, edition: @second_edition, author: @user, body: "Drafted to include new changes.")
      @second_edition.submit!
      @second_edition.publish!
    end

    some_time_passes

    acting_as(@user2) do
      @third_edition = create(:draft_edition, document: @document, major_change_published_at: Time.zone.now)
      some_time_passes
      @third_edition.update!(body: "New draft changes")
      some_time_passes
      create(:editorial_remark, edition: @third_edition, author: @user, body: "Drafted to include newer changes.")
    end
  end

  def some_time_passes
    Timecop.travel rand(1.hour..1.week).from_now
  end
end
