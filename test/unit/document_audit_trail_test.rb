require 'test_helper'

class DocumentAuditTrailTest < ActiveSupport::TestCase
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
  
  test "creation appears as a creation event" do
    doc = create(:draft_document)
    assert_equal 1, doc.audit_trail.size
    assert_equal "create", doc.audit_trail.first.event
    assert_equal @user, doc.audit_trail.first.actor
  end

  test "saving without any changes does not get recorded as an event" do
    doc = create(:draft_document)
    doc.save!
    assert_equal 1, doc.audit_trail.size
  end

  test "saving after changing an attribute records an update event" do
    doc = create(:draft_document)
    doc.title = "foo"
    doc.save!
    assert_equal 2, doc.audit_trail.size
    assert_equal "update", doc.audit_trail.last.event
    assert_equal @user, doc.audit_trail.last.actor
  end

  test "submitting for review records a submitted event" do
    doc = create(:draft_document)
    doc.submit!
    assert_equal 2, doc.audit_trail.size
    assert_equal "submit", doc.audit_trail.last.event
  end

  test "submitting for review records the person who submitted it" do
    doc = create(:draft_document)
    PaperTrail.whodunnit = @user2
    doc.submit!
    assert_equal @user2, doc.audit_trail.last.actor
  end

  test "rejecting records a rejected event" do
    doc = create(:submitted_document)
    PaperTrail.whodunnit = @user2
    doc.reject!
    assert_equal "reject", doc.audit_trail.last.event
    assert_equal @user2, doc.audit_trail.last.actor
  end

  test "publishing records a published event" do
    doc = create(:submitted_document)
    doc.published_at = Time.zone.now
    doc.first_published_at = Time.zone.now
    PaperTrail.whodunnit = @user2
    doc.publish!
    assert_equal "publish", doc.audit_trail.last.event
    assert_equal @user2, doc.audit_trail.last.actor
  end

  test "creating a new draft of a published document records an edition event" do
    doc = create(:published_document)
    policy_writer = create(:policy_writer)
    PaperTrail.whodunnit = policy_writer
    edition = doc.create_draft(policy_writer)
    assert_equal "edition", edition.audit_trail.last.event
    assert_equal policy_writer, edition.audit_trail.last.actor
  end

  test "after creating a new draft, audit events from previous editions still available" do
    doc = create(:published_document)
    previous_events = doc.audit_trail
    edition = doc.create_draft(@user)
    assert_equal previous_events, doc.audit_trail[0..-2]
  end

  test "editorial remark appears as an audit event" do
    Timecop.freeze(Time.zone.now - 2.days)
    doc = create(:draft_document)
    policy_writer = create(:policy_writer)
    editorial_remark_body = "blah"
    Timecop.freeze(Time.zone.now + 1.day)
    doc.editorial_remarks.create!(body: editorial_remark_body, author: policy_writer)
    assert_equal %w{create editorial_remark}, doc.audit_trail.map(&:event)
    assert_equal editorial_remark_body, doc.audit_trail.last.message
  end
end