require 'test_helper'

class Edition::AuditTrailTest < ActiveSupport::TestCase
  def setup
    @previous_whodunnit = Edition::AuditTrail.whodunnit
    @user = create(:user)
    @user2 = create(:user)
    Edition::AuditTrail.whodunnit = @user
  end

  def teardown
    Edition::AuditTrail.whodunnit = @previous_whodunnit
    Timecop.return
  end

  test '#acting_as switches to the supplied user for the duration of the block, returning to the original user afterwards' do
    Edition::AuditTrail.acting_as(@user2) do
      assert_equal @user2, Edition::AuditTrail.whodunnit
    end
    assert_equal @user, Edition::AuditTrail.whodunnit
  end

  test '#acting_as will return to the previous whodunnit, even when an exception is thrown' do
    begin
      Edition::AuditTrail.acting_as(@user2) { raise 'Boom!' }
    rescue
    end

    assert_equal @user, Edition::AuditTrail.whodunnit
  end

  test "creation appears as a creation action" do
    edition = create(:draft_edition)
    assert_equal 1, edition.document_audit_trail.size
    assert_equal "created", edition.document_audit_trail.first.action
    assert_equal @user, edition.document_audit_trail.first.actor
  end

  test "deletion appears as a deletion action" do
    edition = create(:draft_edition)
    edition.delete!
    edition.update_attributes!(state: 'draft')
    assert_equal "deleted", edition.document_audit_trail.second.action
  end

  test "saving without any changes does not get recorded as an action" do
    edition = create(:draft_edition)
    edition.save!
    assert_equal 1, edition.document_audit_trail.size
  end

  test "saving after changing an attribute records an update action" do
    edition = create(:draft_edition)
    edition.title = "foo"
    edition.save!
    assert_equal 2, edition.document_audit_trail.size
    assert_equal "updated", edition.document_audit_trail.last.action
    assert_equal @user, edition.document_audit_trail.last.actor
  end

  test "submitting for review records a submitted action" do
    edition = create(:draft_edition)
    edition.submit!
    assert_equal 2, edition.document_audit_trail.size
    assert_equal "submitted", edition.document_audit_trail.last.action
  end

  test "submitting for review records the person who submitted it" do
    edition = create(:draft_edition)
    Edition::AuditTrail.whodunnit = @user2
    edition.submit!
    assert_equal @user2, edition.document_audit_trail.last.actor
  end

  test "rejecting records a rejected action" do
    edition = create(:submitted_edition)
    Edition::AuditTrail.whodunnit = @user2
    edition.reject!
    assert_equal "rejected", edition.document_audit_trail.last.action
    assert_equal @user2, edition.document_audit_trail.last.actor
  end

  test "publishing records a published action" do
    edition = create(:submitted_edition)
    edition.first_published_at = Time.zone.now
    edition.major_change_published_at = Time.zone.now
    Edition::AuditTrail.whodunnit = @user2
    edition.publish!
    assert_equal "published", edition.document_audit_trail.last.action
    assert_equal @user2, edition.document_audit_trail.last.actor
  end

  test "creating a new draft of a published edition records an edition action" do
    published_edition = create(:published_edition)
    policy_writer = create(:policy_writer)
    Edition::AuditTrail.whodunnit = policy_writer
    draft_edition = published_edition.create_draft(policy_writer)
    assert_equal "editioned", draft_edition.document_audit_trail.last.action
    assert_equal policy_writer, draft_edition.document_audit_trail.last.actor
  end

  test "after creating a new draft, audit events from previous editions still available" do
    published_edition = create(:published_edition)
    previous_events = published_edition.document_audit_trail
    draft_edition = published_edition.create_draft(@user)
    assert_equal previous_events, draft_edition.document_audit_trail[0..-2]
  end

  test "can request audit trail for one edition" do
    published_edition = create(:published_edition)
    policy_writer = create(:policy_writer)
    Edition::AuditTrail.whodunnit = policy_writer
    draft_edition = published_edition.create_draft(policy_writer)
    assert_equal 1, published_edition.edition_audit_trail.size
    assert_equal "editioned", draft_edition.document_audit_trail.last.action
    assert_equal policy_writer, draft_edition.document_audit_trail.last.actor
  end

  test "can request version only trail or remark only trail" do
    published_edition = create(:published_edition)
    policy_writer = create(:policy_writer)
    Edition::AuditTrail.whodunnit = policy_writer
    policy_writer = create(:policy_writer)
    editorial_remark_body = "blah"
    Timecop.freeze(Time.zone.now + 1.day)
    published_edition.editorial_remarks.create!(body: editorial_remark_body, author: policy_writer)
    draft_edition = published_edition.create_draft(policy_writer)
    refute draft_edition.document_version_trail.map(&:object).map(&:class).include? EditorialRemark
    refute draft_edition.document_remarks_trail.map(&:object).map(&:class).include? Version
  end

  test "editorial remark appears as an audit action" do
    Timecop.freeze(Time.zone.now - 2.days)
    edition = create(:draft_edition)
    policy_writer = create(:policy_writer)
    editorial_remark_body = "blah"
    Timecop.freeze(Time.zone.now + 1.day)
    edition.editorial_remarks.create!(body: editorial_remark_body, author: policy_writer)
    assert_equal %w{created editorial_remark}, edition.document_audit_trail.map(&:action)
    assert_equal editorial_remark_body, edition.document_audit_trail.last.message
  end
end
