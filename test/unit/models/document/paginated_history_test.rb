require "test_helper"

class PaginatedHistoryTest < ActiveSupport::TestCase
  setup do
    @per_page = 3

    @user = create(:departmental_editor)
    @user2 = create(:departmental_editor)

    seed_document_event_history
  end

  test "#initialize query contains most recent versions first" do
    history = Document::PaginatedHistory.new(@document, 1)

    assert_equal history.query.first.item_id, @newest_edition.id
  end

  test "#initialize performs queries with pagination" do
    mock_pagination do
      expected_pages = 4
      (1..expected_pages).each do |page|
        history = Document::PaginatedHistory.new(@document, page)
        assert history.query.count <= @per_page
      end
    end
  end

  test "#audit_trail correctly determines action" do
    history = Document::PaginatedHistory.new(@document, 1)
    audit_trail = history.audit_trail
    actual_actions = audit_trail.map(&:action)
    expected_actions = %w[editioned
                          published
                          submitted
                          scheduled
                          submitted
                          scheduled
                          submitted
                          scheduled
                          updated
                          submitted
                          created]

    assert_equal expected_actions, actual_actions
  end

  test "#audit_trail correctly determines actors" do
    history = Document::PaginatedHistory.new(@document, 1)
    audit_trail = history.audit_trail
    actual_actors = audit_trail.map(&:actor)
    expected_actors = [@user,
                       @user,
                       @user,
                       @user2,
                       @user2,
                       @user2,
                       @user2,
                       @user2,
                       @user2,
                       @user,
                       @user]

    assert_equal expected_actors, actual_actors
  end

  test "saving after changing the state records a state change action" do
    @newest_edition.state = "published"
    @newest_edition.save!

    history = Document::PaginatedHistory.new(@document, 1)
    audit_trail = history.audit_trail

    assert_equal "published", audit_trail.first.action
  end

  test "saving without any changes does not get recorded as an action" do
    history_before = Document::PaginatedHistory.new(@document, 1)
    audit_trail_before = history_before.audit_trail

    @newest_edition.save!
    history_after = Document::PaginatedHistory.new(@document, 1)
    audit_trail_after = history_after.audit_trail

    assert_equal audit_trail_before.size, audit_trail_after.size
  end

  test "rejecting records a rejected action" do
    @newest_edition.submit!
    acting_as(@user2) do
      @newest_edition.reject!
    end

    history = Document::PaginatedHistory.new(@document, 1)
    audit_trail = history.audit_trail

    assert_equal "rejected", audit_trail.first.action
    assert_equal @user2, audit_trail.first.actor
  end

  test "saving after changing an attribute without changing the state records an update action" do
    acting_as(@user) do
      @newest_edition.title = "foo"
      @newest_edition.save!
    end

    history = Document::PaginatedHistory.new(@document, 1)
    audit_trail = history.audit_trail

    assert_equal 12, audit_trail.size
    assert_equal "updated", audit_trail.first.action
    assert_equal @user, audit_trail.first.actor
  end

  def seed_document_event_history
    acting_as(@user) do
      @document = create(:document)
      @first_edition = create(:draft_edition, document: @document, major_change_published_at: Time.zone.now)
      Timecop.travel 1.day.from_now
      @first_edition.submit!
      Timecop.travel 1.day.from_now
    end

    acting_as(@user2) do
      @first_edition.versions.create!(event: "updated", state: "submitted", user: @user2)
      Timecop.travel 1.day.from_now
      @first_edition.schedule!
      Timecop.travel 1.day.from_now
      @first_edition.unschedule!
      Timecop.travel 1.day.from_now
      @first_edition.schedule!
      Timecop.travel 1.day.from_now
      @first_edition.unschedule!
      Timecop.travel 1.day.from_now
      @first_edition.schedule!
      Timecop.travel 1.day.from_now
    end

    acting_as(@user) do
      @first_edition.unschedule!
      Timecop.travel 1.day.from_now
      @first_edition.force_publish!
      @newest_edition = create(:draft_edition, document: @document, major_change_published_at: Time.zone.now)
    end
  end

  def mock_pagination(&block)
    Document::PaginatedHistory.stub_const(:PER_PAGE, @per_page, &block)
  end
end
