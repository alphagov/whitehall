# frozen_string_literal: true

require "test_helper"

class Admin::Editions::ChangeNoteComponentTest < ViewComponent::TestCase
  setup do
    @edition = build_stubbed(:published_edition, change_note: "Updated guidance", major_change_published_at: Time.zone.local(2020, 1, 1, 11, 11))
  end

  test "it constructs output based on the change note when a publisher is present" do
    publisher = build_stubbed(:user)
    @edition.stubs(:published_by).returns(publisher)
    change_note = Document::PaginatedTimeline::ChangeNoteDecorator.new(@edition)

    render_inline(Admin::Editions::ChangeNoteComponent.new(change_note:))

    assert_equal page.find("h4").text, "Public change note"
    assert_equal page.all("p")[0].text.strip, "Updated guidance"
    assert_equal page.all("p")[1].text.strip, "1 January 2020 11:11am by #{publisher.name}"
  end

  test "it constructs output based on the change note when a publisher is absent" do
    @edition.stubs(:published_by).returns(nil)
    change_note = Document::PaginatedTimeline::ChangeNoteDecorator.new(@edition)

    render_inline(Admin::Editions::ChangeNoteComponent.new(change_note:))

    assert_equal page.all("p")[1].text.strip, "1 January 2020 11:11am by User (removed)"
  end

  test "it escapes HTML in the change note" do
    @edition.change_note = "Note with <script>a dodgy script</script>."
    @edition.stubs(:published_by).returns(nil)
    change_note = Document::PaginatedTimeline::ChangeNoteDecorator.new(@edition)

    render_inline(Admin::Editions::ChangeNoteComponent.new(change_note:))

    assert_empty page.all("script")
  end
end
