require 'test_helper'

class EditionTest < ActiveSupport::TestCase
  test 'should be valid when built from the factory' do
    edition = Factory.build(:edition)
    assert edition.valid?
  end

  test 'should be invalid without a title' do
    edition = Factory.build(:edition, title: nil)
    assert_not edition.valid?
  end

  test 'should be invalid without a body' do
    edition = Factory.build(:edition, body: nil)
    assert_not edition.valid?
  end

  test 'should be invalid without an author' do
    edition = Factory.build(:edition, author: nil)
    assert_not edition.valid?
  end

  test 'should be invalid without a policy' do
    edition = Factory.build(:edition, policy: nil)
    assert_not edition.valid?
  end

  test 'should be invalid if policy has existing unpublished editions' do
    policy = Factory.create(:policy)
    existing_edition = Factory.create(:draft_edition, policy: policy)
    edition = Factory.build(:edition, policy: policy)
    assert_not edition.valid?
  end

  test 'should only return the draft policies' do
    draft_edition = Factory.create(:draft_edition)
    submitted_edition = Factory.create(:submitted_edition)
    assert_equal [draft_edition], Edition.drafts
  end

  test 'should only return the submitted policies' do
    draft_edition = Factory.create(:draft_edition)
    submitted_edition = Factory.create(:submitted_edition)
    assert_equal [submitted_edition], Edition.submitted
  end

  test 'should not be publishable by the author' do
    author = Factory.create(:departmental_editor)
    edition = Factory.create(:edition, author: author)
    assert_not edition.publish_as!(author)
    assert_not edition.published?
    assert_equal ["You are not the second set of eyes"], edition.errors.full_messages
  end

  test 'should be publishable by departmental editors' do
    author = Factory.create(:policy_writer)
    edition = Factory.create(:edition, author: author)
    other_user = Factory.create(:departmental_editor)
    assert edition.publish_as!(other_user)
    assert edition.published?
  end

  test 'should not return published policies in submitted' do
    edition = Factory.create(:submitted_edition)
    edition.publish_as!(Factory.create(:departmental_editor))
    assert_not Edition.submitted.include?(edition)
  end

  test 'should not be publishable by normal users' do
    edition = Factory.create(:submitted_edition)
    assert_not edition.publish_as!(Factory.create(:policy_writer))
    assert_not edition.published?
    assert_equal ["Only departmental editors can publish policies"], edition.errors.full_messages
  end

  test 'should not be publishable if lock version is not current' do
    editor = Factory.create(:departmental_editor)
    edition = Factory.create(:edition, title: "old title")

    other_instance = Edition.find(edition.id)
    other_instance.update_attributes(title: "new title")

    assert_raises(ActiveRecord::StaleObjectError) do
      assert_not edition.publish_as!(editor, edition.lock_version)
    end
    assert_not Edition.find(edition.id).published?
  end

  test 'should build a draft copy of the existing edition with the supplied author' do
    published_edition = Factory.create(:published_edition)
    new_author = Factory.create(:author)
    draft_edition = published_edition.build_draft(new_author)

    assert draft_edition.new_record?
    assert_not draft_edition.published?
    assert_not draft_edition.submitted?
    assert_equal new_author, draft_edition.author
    assert_equal published_edition.title, draft_edition.title
    assert_equal published_edition.body, draft_edition.body
  end
end