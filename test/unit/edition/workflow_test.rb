require "test_helper"

class Edition::WorkflowTest < ActiveSupport::TestCase

  test "when initially created" do
    edition = create(:edition)
    assert edition.draft?
    refute edition.submitted?
    refute edition.published?
  end

  test "when submitted" do
    edition = create(:submitted_edition)
    refute edition.draft?
    assert edition.submitted?
    refute edition.published?
  end

  test "when published" do
    edition = create(:submitted_edition)
    edition.publish_as(create(:departmental_editor))
    refute edition.draft?
    assert edition.published?
    refute edition.force_published?
  end

  test "when force published" do
    editor = create(:departmental_editor)
    edition = create(:draft_edition, creator: editor)
    edition.publish_as(editor, force: true)
    refute edition.draft?
    assert edition.published?
    assert edition.force_published?
  end

  test "rejecting a submitted edition transitions it into the rejected state" do
    submitted_edition = create(:submitted_edition)
    submitted_edition.reject!
    assert submitted_edition.rejected?
  end

  [:draft, :published, :archived, :deleted].each do |state|
    test "should prevent a #{state} edition being rejected" do
      edition = create("#{state}_edition")
      edition.reject! rescue nil
      refute edition.rejected?
    end
  end

  [:draft, :rejected].each do |state|
    test "submitting a #{state} edition transitions it into the submitted state" do
      edition = create("#{state}_edition")
      edition.submit!
      assert edition.submitted?
    end
  end

  [:published, :archived, :deleted].each do |state|
    test "should prevent a #{state} edition being submitted" do
      edition = create("#{state}_edition")
      edition.submit! rescue nil
      refute edition.submitted?
    end
  end

  [:draft, :submitted, :rejected].each do |state|
    test "deleting a #{state} edition transitions it into the deleted state" do
      edition = create("#{state}_edition")
      edition.delete!
      assert edition.deleted?
    end
  end

  test "should delete a single published edition" do
    edition = create(:published_edition)
    edition.delete!
    assert edition.reload.deleted?
  end

  test "should delete a single archived edition" do
    edition = create(:archived_edition)
    edition.delete!
    assert edition.reload.deleted?
  end

  test "should prevent a published edition with previous editions from being deleted" do
    first_edition = create(:published_edition)
    user = create(:user)
    second_edition = first_edition.create_draft(user)
    second_edition.minor_change = true
    second_edition.publish!
    second_edition.delete!
    refute second_edition.deleted?
  end

  test "should prevent an archived edition with previous editions from being deleted" do
    first_edition = create(:published_edition)
    user = create(:user)
    second_edition = first_edition.create_draft(user)
    second_edition.minor_change = true
    second_edition.publish!
    second_edition.archive!
    second_edition.delete!
    refute second_edition.deleted?
  end

  [:draft, :submitted].each do |state|
    test "publishing a #{state} edition transitions it into the published state" do
      edition = create("#{state}_edition", published_at: 1.day.ago, first_published_at: 1.day.ago)
      edition.publish!
      assert edition.published?
    end
  end

  [:rejected, :archived, :deleted].each do |state|
    test "should prevent a #{state} edition being published" do
      edition = create("#{state}_edition", published_at: 1.day.ago, first_published_at: 1.day.ago)
      edition.publish! rescue nil
      refute edition.published?
    end
  end

  [:draft, :submitted, :rejected, :deleted].each do |state|
    test "should prevent a #{state} edition being archived" do
      edition = create("#{state}_edition")
      edition.archive! rescue nil
      refute edition.archived?
    end
  end

  test "should not find deleted editions by default" do
    deleted_edition = create(:deleted_edition)
    assert_nil Edition.find_by_id(deleted_edition.id)
  end

  [:draft, :submitted, :rejected].each do |state|
    test "should be editable when #{state}" do
      edition = create("#{state}_edition")
      edition.title = "new-title"
      edition.body = "new-body"
      assert edition.valid?
    end
  end

  [:published, :archived, :deleted].each do |state|
    test "should not be editable when #{state}" do
      edition = create("#{state}_edition")
      edition.title = "new-title"
      edition.body = "new-body"
      refute edition.valid?
      assert_equal ["cannot be modified when edition is in the #{state} state"], edition.errors[:title]
      assert_equal ["cannot be modified when edition is in the #{state} state"], edition.errors[:body]
    end
  end

  test "#edit_as updates the edition" do
    attributes = stub(:attributes)
    edition = create(:policy)
    edition.edit_as(create(:user), title: 'new-title')
    assert_equal 'new-title', edition.reload.title
  end

  test "#edit_as records new creator if edit succeeds" do
    edition = create(:policy)
    edition.stubs(:save).returns(true)
    user = create(:user)
    edition.edit_as(user, {})
    assert_equal 2, edition.edition_authors.count
    assert_equal user, edition.edition_authors.last.user
  end

  test "#edit_as returns true if edit succeeds" do
    edition = create(:policy)
    edition.stubs(:save).returns(true)
    assert edition.edit_as(create(:user), {})
  end

  test "#edit_as does not record new creator if edit fails" do
    edition = create(:policy)
    edition.stubs(:save).returns(false)
    user = create(:user)
    edition.edit_as(user, {})
    assert_equal 1, edition.edition_authors.count
  end

  test "#edit_as returns false if edit fails" do
    edition = create(:policy)
    edition.stubs(:save).returns(false)
    refute edition.edit_as(create(:user), {})
  end

  test "#save_as saves the edition" do
    edition = create(:policy)
    edition.expects(:save)
    edition.save_as(create(:user))
  end

  test "#save_as records the new creator if save succeeds" do
    edition = create(:policy)
    edition.stubs(:save).returns(true)
    user = create(:user)
    edition.save_as(user)
    assert_equal 2, edition.edition_authors.count
    assert_equal user, edition.edition_authors.last.user
  end

  test "#save_as does not record new creator if save fails" do
    edition = create(:policy)
    edition.stubs(:save).returns(true)
    user = create(:user)
    edition.save_as(user)
    assert_equal 2, edition.edition_authors.count
    assert_equal user, edition.edition_authors.last.user
  end

  test "#save_as returns true if save succeeds" do
    edition = create(:policy)
    edition.stubs(:save).returns(true)
    assert edition.save_as(create(:user))
  end

  test "#save_as updates the document slug if this is the first draft" do
    edition = create(:submitted_policy, title: "First Title")
    edition.save_as(user = create(:user))

    edition.title = "Second Title"
    edition.save_as(user)
    edition.publish_as(create(:departmental_editor))

    assert_nil Policy.published_as("first-title")
    assert_equal edition, Policy.published_as("second-title")
  end

  test "#save_as does not alter the slug if this edition has previously been published" do
    edition = create(:submitted_policy, title: "First Title")
    edition.save_as(user = create(:user))
    edition.publish_as(editor = create(:departmental_editor))

    new_draft = edition.create_draft(user)
    new_draft.title = "Second Title"
    new_draft.change_note = "change-note"
    new_draft.save_as(user)
    new_draft.submit!
    new_draft.publish_as(editor)

    assert_equal new_draft, Policy.published_as("first-title")
    assert_nil Policy.published_as("second-title")
  end

  test "#save_as returns false if save fails" do
    edition = create(:policy)
    edition.stubs(:save).returns(false)
    refute edition.save_as(create(:user))
  end
end