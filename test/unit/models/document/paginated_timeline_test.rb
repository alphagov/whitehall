require "test_helper"

class PaginatedTimelineTest < ActiveSupport::TestCase
  setup do
    @user = create(:departmental_editor)
    @user2 = create(:departmental_editor)
    seed_document_event_history
  end

  test "#entries are ordered newest first (reverse chronological order)" do
    timeline = Document::PaginatedTimeline.new(document: @document, page: 1)
    entry_timestamps = timeline.entries.map(&:created_at)
    assert_equal entry_timestamps.sort.reverse, entry_timestamps
  end

  test "#entries is a list of AuditTrailEntry and EditorialRemark objects" do
    timeline = Document::PaginatedTimeline.new(document: @document, page: 1)
    assert_equal [Document::PaginatedHistory::AuditTrailEntry, EditorialRemark].to_set,
                 timeline.entries.map(&:class).to_set
  end

  test "#entries are paginated correctly" do
    expect_total_count = 11
    results_per_page = 4
    expect_total_pages = 3

    # Get paginated results
    paginated_results = nil
    mock_pagination(per_page: results_per_page) do
      paginated_results = (1..expect_total_pages).map do |page|
        Document::PaginatedTimeline.new(document: @document, page:).entries
      end
    end

    # Get unpaginated results by setting per_page to the total count
    unpaginated_results = mock_pagination(per_page: expect_total_count) do
      Document::PaginatedTimeline.new(document: @document, page: 1).entries
    end

    # Compare unpaginated results to paginated results
    assert_equal unpaginated_results.each_slice(results_per_page).to_a, paginated_results
  end

  test "it implements methods required by Kaminari for pagination" do
    results_per_page = 4
    expect_total_count = 11
    expect_total_pages = 3

    mock_pagination(per_page: results_per_page) do
      [
        { current_page: 1, next_page: 2, prev_page: false },
        { current_page: 2, next_page: 3, prev_page: 1 },
        { current_page: 3, next_page: false, prev_page: 2 },
      ].each do |expected|
        timeline = Document::PaginatedTimeline.new(document: @document, page: expected[:current_page])
        assert_equal expect_total_count, timeline.total_count
        assert_equal expect_total_pages, timeline.total_pages
        assert_equal results_per_page, timeline.limit_value
        assert_equal expected[:current_page], timeline.current_page
        assert_equal expected[:next_page], timeline.next_page
        assert_equal expected[:prev_page], timeline.prev_page
      end
    end
  end

  test "AuditTrailEntry correctly determines actions" do
    timeline = Document::PaginatedTimeline.new(document: @document, page: 1)
    entries = timeline.entries.select { |e| e.instance_of?(Document::PaginatedHistory::AuditTrailEntry) }
    expected_actions = %w[updated
                          editioned
                          published
                          submitted
                          updated
                          rejected
                          submitted
                          created]

    assert_equal expected_actions, entries.map(&:action)
  end

  test "AuditTrailEntry correctly determines actors" do
    timeline = Document::PaginatedTimeline.new(document: @document, page: 1)
    entries = timeline.entries.select { |e| e.instance_of?(Document::PaginatedHistory::AuditTrailEntry) }
    expected_actors = [@user,
                       @user,
                       @user2,
                       @user,
                       @user,
                       @user2,
                       @user,
                       @user]

    assert_equal expected_actors, entries.map(&:actor)
  end

  test "#entries_on_newer_editions returns entries on newer editions than the one passed in" do
    timeline = Document::PaginatedTimeline.new(document: @document, page: 1)
    expected_entries = timeline.entries.slice(1, 2)

    assert_equal expected_entries, timeline.entries_on_newer_editions(timeline.entries, @first_edition)
  end

  test "#entries_on_current_edition returns entries for the edition passed in" do
    timeline = Document::PaginatedTimeline.new(document: @document, page: 1)
    expected_entries = timeline.entries - timeline.entries.slice(1, 2)

    assert_equal expected_entries, timeline.entries_on_current_edition(timeline.entries, @first_edition)
  end

  test "#entries_on_previous_editions returns entries on previous editions" do
    timeline = Document::PaginatedTimeline.new(document: @document, page: 1)
    expected_entries = timeline.entries - timeline.entries.slice(1, 2)

    assert_equal expected_entries, timeline.entries_on_previous_editions(timeline.entries, @newest_edition)
  end

  def seed_document_event_history
    acting_as(@user) do
      @document = create(:document)
      @first_edition = create(:draft_edition, document: @document, major_change_published_at: Time.zone.now)
      some_time_passes
      @first_edition.submit!
    end

    some_time_passes

    acting_as(@user2) do
      create(:editorial_remark, edition: @first_edition, author: @user2, body: "This is terrible. Make it better!")
      some_time_passes
      @first_edition.reject!
    end

    some_time_passes

    acting_as(@user) do
      @first_edition.update!(body: "New and improved")
      some_time_passes
      create(:editorial_remark, edition: @first_edition, author: @user, body: "I've made it better.")
      some_time_passes
      @first_edition.submit!
    end

    some_time_passes

    acting_as(@user2) do
      @first_edition.publish!
    end

    some_time_passes

    acting_as(@user) do
      @newest_edition = create(:draft_edition, document: @document, major_change_published_at: Time.zone.now)
      some_time_passes
      @newest_edition.update!(body: "New draft changes")
      some_time_passes
      create(:editorial_remark, edition: @first_edition, author: @user, body: "Drafted to include new changes.")
    end
  end

  def mock_pagination(per_page:, &block)
    Document::PaginatedTimeline.stub_const(:PER_PAGE, per_page, &block)
  end

  def some_time_passes
    Timecop.travel rand(1.hour..1.week).from_now
  end
end
