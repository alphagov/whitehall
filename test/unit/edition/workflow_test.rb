require "test_helper"

class Edition::WorkflowTest < ActiveSupport::TestCase

  test "when initially created" do
    edition = create(:edition)
    refute edition.imported?
    assert edition.draft?
    refute edition.submitted?
    refute edition.scheduled?
    refute edition.published?
  end

  test "when imported" do
    edition = create(:imported_edition)
    assert edition.imported?
    refute edition.draft?
    refute edition.submitted?
    refute edition.scheduled?
    refute edition.published?
  end

  test "when submitted" do
    edition = create(:submitted_edition)
    refute edition.imported?
    refute edition.draft?
    assert edition.submitted?
    refute edition.scheduled?
    refute edition.published?
  end

  test "when published" do
    edition = create(:submitted_edition)
    EditionPublisher.new(edition).perform!
    refute edition.imported?
    refute edition.draft?
    assert edition.published?
    refute edition.scheduled?
    refute edition.force_published?
  end

  test "when force published" do
    editor = create(:departmental_editor)
    edition = create(:draft_edition, creator: editor)
    force_publish(edition)
    refute edition.imported?
    refute edition.draft?
    assert edition.published?
    refute edition.scheduled?
    assert edition.force_published?
  end

  test "when scheduled" do
    edition = create(:submitted_edition, scheduled_publication: 1.day.from_now)
    edition.perform_schedule
    refute edition.imported?
    refute edition.draft?
    refute edition.published?
    assert edition.scheduled?
    refute edition.force_published?
  end

  test "indicates pre-publication status" do
    pre, post = Edition.state_machine.states.map(&:name).partition do |state|
      if state == :deleted
        create(:edition, state)
      else
        build(:edition, state)
      end.pre_publication?
    end

    assert_equal [:imported, :draft, :submitted, :rejected, :scheduled], pre
    assert_equal [:published, :archived, :superseded, :deleted], post
  end

  test "rejecting a submitted edition transitions it into the rejected state" do
    submitted_edition = create(:submitted_edition)
    submitted_edition.reject!
    assert submitted_edition.rejected?
  end

  [:draft, :scheduled, :published, :archived, :deleted].each do |state|
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

  [:scheduled, :published, :archived, :deleted].each do |state|
    test "should prevent a #{state} edition being submitted" do
      edition = create("#{state}_edition")
      edition.submit! rescue nil
      refute edition.submitted?
    end
  end

  [:imported, :draft, :submitted, :rejected].each do |state|
    test "deleting a #{state} edition transitions it into the deleted state" do
      edition = create("#{state}_edition")
      edition.delete!
      assert edition.deleted?
    end
  end

  [:scheduled, :published, :archived].each do |state|
    test "should prevent a #{state} edition being deleted" do
      edition = create("#{state}_edition")
      edition.delete! rescue nil
      refute edition.deleted?
    end
  end

  [:submitted, :scheduled].each do |state|
    test "publishing a #{state} edition transitions it into the published state" do
      edition = create("#{state}_edition", major_change_published_at: 1.day.ago)
      edition.publish!
      assert edition.published?
    end
  end

  [:draft, :submitted].each do |state|
    test " force publishing a #{state} edition transitions it into the published state" do
      edition = create("#{state}_edition", major_change_published_at: 1.day.ago)
      edition.force_publish!
      assert edition.published?
    end
  end

  [:rejected, :archived, :deleted].each do |state|
    test "should prevent a #{state} edition being published" do
      edition = create("#{state}_edition")
      edition.publish! rescue nil
      refute edition.published?
    end
  end

  test "unpublishing a published edition transitions it into the draft state" do
    edition = create(:published_edition)
    edition.unpublish!
    assert edition.draft?
  end

  test "unpublishing a force published edition removes the force published flag" do
    edition = create(:published_edition, force_published: true)
    edition.unpublish!
    refute edition.force_published?
  end

  [:submitted, :scheduled, :rejected, :archived, :deleted].each do |state|
    test "should prevent a #{state} edition being unpublished" do
      edition = create("#{state}_edition")
      edition.unpublish! rescue nil
      refute edition.draft?
    end
  end

  test 'prevents unpublishing if there is a draft in place already' do
    edition = create(:published_edition)
    draft = edition.create_draft(edition.creator)
    edition.unpublish! rescue nil
    refute edition.draft?
  end

  test "should allow a submitted edition to be scheduled if it has a scheduled date" do
    edition = create("submitted_edition", scheduled_publication: 1.day.from_now)
    edition.schedule!
    refute edition.published?
    assert edition.scheduled?
  end

  test "should prevent a submitted edition from being scheduled if it does not have a scheduled date" do
    edition = create("submitted_edition", scheduled_publication: nil)
    edition.schedule!
    refute edition.scheduled?
  end

  [:draft, :submitted, :scheduled, :rejected, :deleted].each do |state|
    test "should prevent a #{state} edition being archived" do
      edition = create("#{state}_edition")
      edition.archive! rescue nil
      refute edition.archived?
    end
  end

  test "should not find deleted editions by default" do
    edition = create(:draft_edition)
    edition.delete!
    assert_nil Edition.find_by_id(edition.id)
  end

  [:draft, :submitted, :rejected].each do |state|
    test "should be editable when #{state}" do
      edition = create("#{state}_edition")
      edition.title = "new-title"
      edition.body = "new-body"
      assert edition.valid?
    end
  end

  [:scheduled, :published, :archived, :deleted].each do |state|
    test "should not be editable when #{state}" do
      edition = create("#{state}_edition")
      edition.title = "new-title"
      edition.body = "new-body"
      refute edition.valid?
      assert_equal ["cannot be modified when edition is in the #{state} state"], edition.errors[:title]
      assert_equal ["cannot be modified when edition is in the #{state} state"], edition.errors[:body]
    end
  end

  test "should be able to change major_change_published_at and first_published_at when scheduled" do
    edition = create(:edition, :scheduled)
    edition.first_published_at = Time.zone.now
    edition.major_change_published_at = Time.zone.now
    assert edition.valid?
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
    EditionPublisher.new(edition).perform!

    assert_nil Policy.published_as("first-title")
    assert_equal edition, Policy.published_as("second-title")
  end

  test "#save_as does not alter the slug if this edition has previously been published" do
    edition = create(:submitted_policy, title: "First Title")
    edition.save_as(user = create(:user))
    EditionPublisher.new(edition).perform!

    new_draft = edition.create_draft(user)
    new_draft.title = "Second Title"
    new_draft.change_note = "change-note"
    new_draft.save_as(user)
    new_draft.submit!
    EditionPublisher.new(new_draft).perform!

    assert_equal new_draft, Policy.published_as("first-title")
    assert_nil Policy.published_as("second-title")
  end

  test "#save_as returns false if save fails" do
    edition = create(:policy)
    edition.stubs(:save).returns(false)
    refute edition.save_as(create(:user))
  end

  # This is a quick fix to deal with a specific instance of the larger
  # workflow issue that you cannot archive a document which fails
  # validation.
  test "can archive a detailed guide without a user need" do
    detailed_guide = create(:published_detailed_guide)

    detailed_guide.update_attribute(:user_needs, [])
    refute detailed_guide.valid?

    detailed_guide.archive! rescue nil
    assert detailed_guide.archived?
  end
end
