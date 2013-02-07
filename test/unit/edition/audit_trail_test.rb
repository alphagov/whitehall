require 'test_helper'

class Edition::AuditTrailTest < ActiveSupport::TestCase
  def setup
    @previous_whodunnit = PaperTrail.whodunnit
    @user = create(:user)
    @user2 = create(:user)
    PaperTrail.whodunnit = @user
  end

  def teardown
    PaperTrail.whodunnit = @previous_whodunnit
    Timecop.return
  end

  test "creation appears as a creation action" do
    doc = create(:draft_edition)
    assert_equal 1, doc.audit_trail.size
    assert_equal "created", doc.audit_trail.first.action
    assert_equal @user, doc.audit_trail.first.actor
  end

  test "deletion appears as a deletion action" do
    edition = create(:draft_edition)
    edition.delete!
    edition.update_attributes!(state: 'draft')
    assert_equal "deleted", edition.audit_trail.second.action
  end

  test "saving without any changes does not get recorded as an action" do
    doc = create(:draft_edition)
    doc.save!
    assert_equal 1, doc.audit_trail.size
  end

  test "saving after changing an attribute records an update action" do
    doc = create(:draft_edition)
    doc.title = "foo"
    doc.save!
    assert_equal 2, doc.audit_trail.size
    assert_equal "updated", doc.audit_trail.last.action
    assert_equal @user, doc.audit_trail.last.actor
  end

  test "submitting for review records a submitted action" do
    doc = create(:draft_edition)
    doc.submit!
    assert_equal 2, doc.audit_trail.size
    assert_equal "submitted", doc.audit_trail.last.action
  end

  test "submitting for review records the person who submitted it" do
    doc = create(:draft_edition)
    PaperTrail.whodunnit = @user2
    doc.submit!
    assert_equal @user2, doc.audit_trail.last.actor
  end

  test "rejecting records a rejected action" do
    doc = create(:submitted_edition)
    PaperTrail.whodunnit = @user2
    doc.reject!
    assert_equal "rejected", doc.audit_trail.last.action
    assert_equal @user2, doc.audit_trail.last.actor
  end

  test "publishing records a published action" do
    doc = create(:submitted_edition)
    doc.first_published_at = Time.zone.now
    doc.major_change_published_at = Time.zone.now
    PaperTrail.whodunnit = @user2
    doc.publish!
    assert_equal "published", doc.audit_trail.last.action
    assert_equal @user2, doc.audit_trail.last.actor
  end

  test "creating a new draft of a published edition records an edition action" do
    doc = create(:published_edition)
    policy_writer = create(:policy_writer)
    PaperTrail.whodunnit = policy_writer
    edition = doc.create_draft(policy_writer)
    assert_equal "editioned", edition.audit_trail.last.action
    assert_equal policy_writer, edition.audit_trail.last.actor
  end

  test "after creating a new draft, audit events from previous editions still available" do
    doc = create(:published_edition)
    previous_events = doc.audit_trail
    edition = doc.create_draft(@user)
    assert_equal previous_events, doc.audit_trail[0..-2]
  end

  test "can request audit trail for one edition" do
    doc = create(:published_edition)
    policy_writer = create(:policy_writer)
    PaperTrail.whodunnit = policy_writer
    edition = doc.create_draft(policy_writer)
    assert_equal 1, doc.edition_audit_trail.size
    assert_equal "editioned", edition.audit_trail.last.action
    assert_equal policy_writer, edition.audit_trail.last.actor
  end

  test "editorial remark appears as an audit action" do
    Timecop.freeze(Time.zone.now - 2.days)
    doc = create(:draft_edition)
    policy_writer = create(:policy_writer)
    editorial_remark_body = "blah"
    Timecop.freeze(Time.zone.now + 1.day)
    doc.editorial_remarks.create!(body: editorial_remark_body, author: policy_writer)
    assert_equal %w{created editorial_remark}, doc.audit_trail.map(&:action)
    assert_equal editorial_remark_body, doc.audit_trail.last.message
  end
end
