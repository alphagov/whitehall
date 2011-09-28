require 'test_helper'

class EditionTest < ActiveSupport::TestCase
  test 'should be valid when built from the factory' do
    edition = build(:edition)
    assert edition.valid?
  end

  test 'should be invalid without a title' do
    edition = build(:edition, title: nil)
    assert_not edition.valid?
  end

  test 'should be invalid without a body' do
    edition = build(:edition, body: nil)
    assert_not edition.valid?
  end

  test 'should be invalid without an author' do
    edition = build(:edition, author: nil)
    assert_not edition.valid?
  end

  test 'should be invalid without a policy' do
    edition = build(:edition, policy: nil)
    assert_not edition.valid?
  end

  test 'should be invalid if policy has existing unpublished editions' do
    policy = create(:policy)
    existing_edition = create(:draft_edition, policy: policy)
    edition = build(:edition, policy: policy)
    assert_not edition.valid?
  end

  test 'should be invalid when published if policy has existing published editions' do
    policy = create(:policy)
    existing_edition = create(:published_edition, policy: policy)
    edition = build(:published_edition, policy: policy)
    assert_not edition.valid?
  end

  test 'should only return unsubmitted draft policies' do
    draft_edition = create(:draft_edition)
    submitted_edition = create(:submitted_edition)
    assert_equal [draft_edition], Edition.unsubmitted
  end

  test 'should only return the submitted policies' do
    draft_edition = create(:draft_edition)
    submitted_edition = create(:submitted_edition)
    assert_equal [submitted_edition], Edition.submitted
  end

  test 'should not be publishable when not submitted' do
    edition = create(:draft_edition)
    refute edition.publishable_by?(create(:departmental_editor))
  end

  test 'should fail publication when not submitted' do
    edition = create(:draft_edition)
    edition.publish_as!(create(:departmental_editor))
    assert_not edition.published?
  end

  test 'should not be publishable when already published' do
    edition = create(:published_edition)
    refute edition.publishable_by?(create(:departmental_editor))
  end

  test 'should fail publication when already published' do
    edition = create(:published_edition)
    refute edition.publish_as!(create(:departmental_editor))
    assert_equal ["This edition has already been published"], edition.errors.full_messages
  end

  test 'should not be publishable by the original author' do
    author = create(:departmental_editor)
    edition = create(:submitted_edition, author: author)
    refute edition.publishable_by?(author)
  end

  test 'should fail publication by the author' do
    author = create(:departmental_editor)
    edition = create(:submitted_edition, author: author)
    assert_not edition.publish_as!(author)
    assert_not edition.published?
    assert_equal ["You are not the second set of eyes"], edition.errors.full_messages
  end

  test 'should be publishable by departmental editors' do
    edition = create(:submitted_edition)
    departmental_editor = create(:departmental_editor)
    assert edition.publishable_by?(departmental_editor)
  end

  test 'should succeed publication when published by departmental editors' do
    author = create(:policy_writer)
    edition = create(:submitted_edition, author: author)
    other_user = create(:departmental_editor)
    assert edition.publish_as!(other_user)
    assert edition.published?
  end

  test 'should not return published policies in submitted' do
    edition = create(:submitted_edition)
    edition.publish_as!(create(:departmental_editor))
    assert_not Edition.submitted.include?(edition)
  end

  test 'should fail publication by normal users' do
    edition = create(:submitted_edition)
    assert_not edition.publish_as!(create(:policy_writer))
    assert_not edition.published?
    assert_equal ["Only departmental editors can publish policies"], edition.errors.full_messages
  end

  test 'should fail publication if lock version is not current' do
    editor = create(:departmental_editor)
    edition = create(:submitted_edition, title: "old title")

    other_instance = Edition.find(edition.id)
    other_instance.update_attributes(title: "new title")

    assert_raises(ActiveRecord::StaleObjectError) do
      assert_not edition.publish_as!(editor, edition.lock_version)
    end
    assert_not Edition.find(edition.id).published?
  end

  test 'should archive earlier editions on publication' do
    published_edition = create(:published_edition)
    author = create(:policy_writer)
    edition = create(:submitted_edition, policy: published_edition.policy, author: author)
    editor = create(:departmental_editor)
    edition.publish_as!(editor)

    published_edition.reload
    assert published_edition.archived?
  end

  test 'should not be publishable when archived' do
    edition = create(:archived_edition)
    refute edition.publishable_by?(create(:departmental_editor))
  end

  test 'should build a draft copy of the existing edition with the supplied author' do
    published_edition = create(:published_edition, submitted: true)
    new_author = create(:policy_writer)
    draft_edition = published_edition.build_draft(new_author)

    assert draft_edition.new_record?
    assert_not draft_edition.published?
    assert_not draft_edition.submitted?
    assert_equal new_author, draft_edition.author
    assert_equal published_edition.title, draft_edition.title
    assert_equal published_edition.body, draft_edition.body
  end

  test 'when initially created' do
    edition = create(:edition)
    assert edition.draft?
    assert_not edition.submitted?
    assert_not edition.published?
  end

  test 'when submitted' do
    edition = create(:submitted_edition)
    assert edition.draft?
    assert edition.submitted?
    assert_not edition.published?
  end

  test 'when published' do
    edition = create(:submitted_edition)
    edition.publish_as!(create(:departmental_editor))
    assert_not edition.draft?
    assert edition.published?
  end

end