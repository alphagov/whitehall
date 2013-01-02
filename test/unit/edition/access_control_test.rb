require "test_helper"

class Edition::AccessControlTest < ActiveSupport::TestCase

  [:imported, :draft, :submitted, :rejected].each do |state|
    test "should be editable if #{state}" do
      edition = build("#{state}_edition")
      assert edition.editable?
    end
  end

  [:published, :archived, :deleted].each do |state|
    test "should not be editable if #{state}" do
      edition = create("#{state}_edition")
      refute edition.editable?
    end
  end

  [:imported, :deleted].each do |state|
    test "can have some invalid data if #{state}" do
      edition = create("#{state}_edition")
      assert edition.can_have_some_invalid_data?
    end
  end

  [:draft, :submitted, :rejected, :published, :archived].each do |state|
    test "cannot have some invalid data if #{state}" do
      edition = build("#{state}_edition")
      refute edition.can_have_some_invalid_data?
    end
  end

  test "should be rejectable by editors if submitted" do
    edition = build(:submitted_edition)
    assert edition.rejectable_by?(build(:departmental_editor))
  end

  test "should not be rejectable by writers" do
    edition = build(:submitted_edition)
    refute edition.rejectable_by?(build(:policy_writer))
  end

  [:draft, :rejected, :published, :archived, :deleted].each do |state|
    test "should not be rejectable if #{state}" do
      edition = create("#{state}_edition")
      refute edition.rejectable_by?(build(:departmental_editor))
    end
  end

  [:draft, :rejected].each do |state|
    test "should be submittable if #{state}" do
      edition = build("#{state}_edition")
      assert edition.submittable?
    end
  end

  [:submitted, :published, :archived, :deleted].each do |state|
    test "should not be submittable if #{state}" do
      edition = create("#{state}_edition")
      refute edition.submittable?
    end
  end

  [:imported, :draft, :submitted, :rejected].each do |state|
    test "should be deletable if #{state}" do
      edition = create("#{state}_edition")
      assert edition.deletable?
    end
  end

  [:scheduled, :published, :archived].each do |state|
    test "should not be deletable if #{state}" do
      document = create("#{state}_edition")
      refute document.deletable?
    end
  end

  test 'is ready to convert to draft if it is imported and valid as a draft' do
    document = build(:imported_edition)
    document.stubs(:valid_as_draft?).returns(true)
    assert document.ready_to_convert_to_draft?
  end

  test 'is not ready to convert to draft if it is imported but not valid as a draft' do
    document = build(:imported_edition)
    document.stubs(:valid_as_draft?).returns(false)
    refute document.ready_to_convert_to_draft?
  end

  [:draft, :scheduled, :published, :archived, :submitted, :rejected].each do |state|
    test "is not ready to convert to draft if it is #{state}" do
      document = build("#{state}_edition")
      refute document.ready_to_convert_to_draft?
    end
  end

  test "should not be deletable if deleted" do
    document = create("draft_edition")
    document.delete!
    refute document.deletable?
  end

  test "should allow another editor to retrospectively approve a force-published document" do
    editor, other_editor = create(:departmental_editor), create(:departmental_editor)
    edition = create(:submitted_policy)
    acting_as(editor) { edition.publish_as(editor, force: true) }
    assert edition.approvable_retrospectively_by?(other_editor)
  end

  test "should not allow the same editor to retrospectively approve a force-published document" do
    editor = create(:departmental_editor)
    edition = create(:submitted_policy)
    acting_as(editor) { edition.publish_as(editor, force: true) }
    refute edition.approvable_retrospectively_by?(editor)
  end

  test "should not allow a writer to retrospectively approve a force-published document" do
    edition = create(:published_edition, force_published: true)
    policy_writer = create(:policy_writer)
    refute edition.approvable_retrospectively_by?(policy_writer)
  end

  test "should not allow a document that was not force-published to be retrospectively approved" do
    edition = create(:published_edition, force_published: false)
    editor = create(:departmental_editor)
    refute edition.approvable_retrospectively_by?(editor)
  end

  test "should allow another editor to retrospectively approve a force-scheduled document" do
    editor, other_editor = create(:departmental_editor), create(:departmental_editor)
    edition = create(:submitted_publication, scheduled_publication: 1.day.from_now)
    acting_as(editor) { edition.schedule_as(editor, force: true) }
    assert edition.approvable_retrospectively_by?(other_editor)
  end

  test "should not allow the same editor to retrospectively approve a force-scheduled document" do
    editor = create(:departmental_editor)
    edition = create(:submitted_policy, scheduled_publication: 1.day.from_now)
    acting_as(editor) { assert edition.schedule_as(editor, force: true) }
    refute edition.approvable_retrospectively_by?(editor)
  end

  test "should not allow the same editor to retrospectively approve a force-scheduled document, even after publication" do
    editor = create(:departmental_editor)
    robot = create(:scheduled_publishing_robot)
    edition = create(:submitted_policy, scheduled_publication: 1.day.from_now)
    acting_as(editor) { assert edition.schedule_as(editor, force: true) }
    Timecop.freeze edition.scheduled_publication do
      acting_as(robot) { assert edition.publish_as(robot) }
      refute edition.approvable_retrospectively_by?(editor)
    end
  end

  test "should not allow a writer to retrospectively approve a force-scheduled document" do
    edition = create(:scheduled_edition, force_published: true)
    policy_writer = create(:policy_writer)
    refute edition.approvable_retrospectively_by?(policy_writer)
  end

  test "should not allow a document that was not force-scheduled to be retrospectively approved" do
    edition = create(:scheduled_edition, force_published: false)
    editor = create(:departmental_editor)
    refute edition.approvable_retrospectively_by?(editor)
  end
end
