require "test_helper"

class ChangeNoteFormTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  test "is invalid when minor_change is not present" do
    change_note_form = ChangeNoteForm.new(change_note: "This is present", minor_change: nil)
    assert_not change_note_form.valid?
  end

  test "is invalid when it is a major change and change_note is not present" do
    change_note_form = ChangeNoteForm.new(change_note: nil, minor_change: false)
    assert_not change_note_form.valid?
  end

  test "is valid when it is a minor change and a change_note is not present" do
    change_note_form = ChangeNoteForm.new(change_note: nil, minor_change: true)
    assert change_note_form.valid?
  end

  test "is valid when it is a major change and change_note is present" do
    change_note_form = ChangeNoteForm.new(change_note: "This is present", minor_change: false)
    assert change_note_form.valid?
  end

  test "#save returns false and adds errors to the form object when invalid" do
    change_note_form = ChangeNoteForm.new
    edition = build(:edition)

    assert_equal false, change_note_form.save!(edition)
    assert_equal ["Change note #{I18n.t('activemodel.errors.models.change_note_form.attributes.change_note.blank')}"], change_note_form.errors.full_messages
  end

  test "#save updates the edition successfully when it is a major change and a change note is present" do
    edition = create(:edition)
    change_note_form = ChangeNoteForm.new(change_note: "This is present", minor_change: "false")

    change_note_form.save!(edition)

    assert_equal "This is present", edition.reload.change_note
    assert_equal false, edition.minor_change
  end

  test "#save updates the edition successfully and sets the change note to nil when it is a minor change" do
    edition = create(:edition, change_note: "Lots of changes.")
    change_note_form = ChangeNoteForm.new(change_note: "I'm still present", minor_change: "true")

    change_note_form.save!(edition)

    assert_equal nil, edition.reload.change_note
    assert_equal true, edition.minor_change
  end
end
