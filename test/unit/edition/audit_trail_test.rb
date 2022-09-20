require "test_helper"

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

  test "#acting_as switches to the supplied user for the duration of the block, returning to the original user afterwards" do
    Edition::AuditTrail.acting_as(@user2) do
      assert_equal @user2, Edition::AuditTrail.whodunnit
    end
    assert_equal @user, Edition::AuditTrail.whodunnit
  end

  test "#acting_as will return to the previous whodunnit, even when an exception is thrown" do
    begin
      Edition::AuditTrail.acting_as(@user2) { raise "Boom!" }
    rescue StandardError # rubocop:disable Lint/SuppressedException
    end

    assert_equal @user, Edition::AuditTrail.whodunnit
  end

  test "creation appears as a creation action" do
    edition = create(:draft_edition)
    assert_equal 1, edition.document_version_trail.size
    assert_equal "created", edition.document_version_trail.first.action
    assert_equal @user, edition.document_version_trail.first.actor
  end

  test "saving after changing the state records a state change action" do
    edition = create(:draft_edition)
    edition.state = "published"
    edition.save!

    assert_equal "published", edition.document_version_trail.second.action
  end

  test "saving without any changes does not get recorded as an action" do
    edition = create(:draft_edition)
    edition.save!
    assert_equal 1, edition.document_version_trail.size
  end

  test "saving after changing an attribute without changing the state records an update action" do
    edition = create(:draft_edition)
    edition.title = "foo"
    edition.save!
    assert_equal 2, edition.document_version_trail.size
    assert_equal "updated", edition.document_version_trail.last.action
    assert_equal @user, edition.document_version_trail.last.actor
  end

  test "submitting for review records a submitted action" do
    edition = create(:draft_edition)
    edition.submit!
    assert_equal 2, edition.document_version_trail.size
    assert_equal "submitted", edition.document_version_trail.last.action
  end

  test "submitting for review records the person who submitted it" do
    edition = create(:draft_edition)
    Edition::AuditTrail.whodunnit = @user2
    edition.submit!
    assert_equal @user2, edition.document_version_trail.last.actor
  end

  test "rejecting records a rejected action" do
    edition = create(:submitted_edition)
    Edition::AuditTrail.whodunnit = @user2
    edition.reject!
    assert_equal "rejected", edition.document_version_trail.last.action
    assert_equal @user2, edition.document_version_trail.last.actor
  end

  test "publishing records a published action" do
    edition = create(:submitted_edition)
    edition.first_published_at = Time.zone.now
    edition.major_change_published_at = Time.zone.now
    Edition::AuditTrail.whodunnit = @user2
    edition.publish!
    assert_equal "published", edition.document_version_trail.last.action
    assert_equal @user2, edition.document_version_trail.last.actor
  end

  test "creating a new draft of a published edition records an edition action" do
    published_edition = create(:published_edition)
    writer = create(:writer)
    Edition::AuditTrail.whodunnit = writer
    draft_edition = published_edition.create_draft(writer)
    assert_equal "editioned", draft_edition.document_version_trail.last.action
    assert_equal writer, draft_edition.document_version_trail.last.actor
  end

  test "after creating a new draft, audit events from previous editions still available" do
    published_edition = create(:published_edition)
    previous_events = published_edition.document_version_trail
    draft_edition = published_edition.create_draft(@user)
    assert_equal previous_events, draft_edition.document_version_trail[0..-2]
  end
end
