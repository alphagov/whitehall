require "test_helper"

class PaginatedTimelineTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  setup do
    @user = create(:departmental_editor)
    @user2 = create(:departmental_editor)
    HostContentUpdateEvent.stubs(:all_for_date_window).returns([])
    seed_document_event_history
  end

  describe "#entries" do
    it "orders newest first (reverse chronological order)" do
      timeline = Document::PaginatedTimeline.new(document: @document, page: 1)
      entry_timestamps = timeline.entries.map(&:created_at)
      assert_equal entry_timestamps.sort.reverse, entry_timestamps
    end

    it "is a list of Document::PaginatedTimeline::VersionDecorator and EditorialRemark objects when 'only' argument is not present" do
      timeline = Document::PaginatedTimeline.new(document: @document, page: 1)
      assert_equal [Document::PaginatedTimeline::VersionDecorator, EditorialRemark].to_set,
                   timeline.entries.map(&:class).to_set
    end

    it "paginates correctly" do
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

    it "correctly determines actions" do
      mock_pagination(per_page: 30) do
        timeline = Document::PaginatedTimeline.new(document: @document, page: 1)
        entries = timeline.entries.select { |e| e.instance_of?(Document::PaginatedTimeline::VersionDecorator) }
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
    end

    it "correctly determines actors" do
      timeline = Document::PaginatedTimeline.new(document: @document, page: 1)
      entries = timeline.entries.select { |e| e.instance_of?(Document::PaginatedTimeline::VersionDecorator) }
      expected_actors = [@user,
                         @user,
                         @user2,
                         @user,
                         @user,
                         @user2,
                         @user]

      assert_equal expected_actors, entries.map(&:actor)
    end

    describe "when there are HostContentUpdateEvents present" do
      let(:host_content_update_events) { build_list(:host_content_update_event, 3) }

      before do
        HostContentUpdateEvent.stubs(:all_for_date_window).returns(host_content_update_events)
      end

      it "orders newest first (reverse chronological order)" do
        timeline = Document::PaginatedTimeline.new(document: @document, page: 1)
        entry_timestamps = timeline.entries.flatten.map(&:created_at)
        assert_equal entry_timestamps.sort.reverse, entry_timestamps
      end

      it "is a list of Document::PaginatedTimeline::VersionDecorator and EditorialRemark and HostContentUpdateEvent objects when 'only' argument is not present" do
        timeline = Document::PaginatedTimeline.new(document: @document, page: 1)
        assert_equal [Document::PaginatedTimeline::VersionDecorator, EditorialRemark, HostContentUpdateEvent].to_set,
                     timeline.entries.map(&:class).to_set
      end

      it "includes all of the HostContentUpdateEvent objects" do
        timeline = Document::PaginatedTimeline.new(document: @document, page: 1)

        host_content_update_events.each do |event|
          assert_includes timeline.entries, event
        end
      end

      describe "fetching HostContentUpdateEvents" do
        before do
          HostContentUpdateEvent.reset_mocha
        end

        describe "when on the first page" do
          it "requests a date window from the first created_at date of the next page to the current datetime" do
            Timecop.freeze do
              page2_entries = Document::PaginatedTimeline.new(document: @document, page: 2).query.raw_entries

              HostContentUpdateEvent.expects(:all_for_date_window).with(
                document: @document,
                from: page2_entries.first.created_at.to_time.utc,
                to: Time.zone.now.to_time.round.utc,
              ).at_least_once.returns(host_content_update_events)

              Document::PaginatedTimeline.new(document: @document, page: 1).entries
            end
          end

          describe "when there are no results" do
            it "does not request any events" do
              timeline = Document::PaginatedTimeline.new(document: @document, page: 1)
              timeline.query.expects(:raw_entries).at_least_once.returns([])

              HostContentUpdateEvent.expects(:all_for_date_window).never

              timeline.entries
            end
          end
        end

        describe "when not on the first page" do
          it "requests a window between the first created_at date of the next page to the first created_at date of the current page" do
            mock_pagination(per_page: 3) do
              page2_entries = Document::PaginatedTimeline.new(document: @document, page: 2).query.raw_entries
              page3_entries = Document::PaginatedTimeline.new(document: @document, page: 3).query.raw_entries

              HostContentUpdateEvent.expects(:all_for_date_window).with(
                document: @document,
                from: page3_entries.first.created_at.to_time.utc,
                to: page2_entries.first.created_at.to_time.utc,
              ).at_least_once.returns(host_content_update_events)

              Document::PaginatedTimeline.new(document: @document, page: 2).entries
            end
          end
        end

        describe "when on the last page" do
          it "fetches with the created_at date for the last item" do
            Timecop.freeze do
              mock_pagination(per_page: 30) do
                timeline = Document::PaginatedTimeline.new(document: @document, page: 1)
                timeline_entries = timeline.query.raw_entries

                HostContentUpdateEvent.expects(:all_for_date_window).with(
                  document: @document,
                  from: timeline_entries.last.created_at.to_time.utc,
                  to: timeline_entries.first.created_at.to_time.utc,
                ).at_least_once.returns(host_content_update_events)

                timeline.entries
              end
            end
          end
        end
      end
    end

    describe "when only argument is set to history" do
      it "is a list of Document::PaginatedTimeline::VersionDecorator objects" do
        timeline = Document::PaginatedTimeline.new(document: @document, page: 1, only: "history")
        expected_actions = %w[updated
                              editioned
                              published
                              submitted
                              updated
                              rejected
                              submitted
                              created]

        assert_equal expected_actions, timeline.entries.map(&:action)
      end

      it "does not fetch any HostContentUpdateEvents" do
        HostContentUpdateEvent.expects(:all_for_date_window).never

        Document::PaginatedTimeline.new(document: @document, page: 1, only: "history").entries
      end
    end

    describe "when only argument is set to internal_notes" do
      it "is a list of EditorialRemark objects when 'internal_notes'" do
        timeline = Document::PaginatedTimeline.new(document: @document, page: 1, only: "internal_notes")
        expected_entries = [@editorial_remark3, @editorial_remark2, @editorial_remark1]

        assert_equal expected_entries, timeline.entries
      end

      it "does not fetch any HostContentUpdateEvents" do
        HostContentUpdateEvent.expects(:all_for_date_window).never

        Document::PaginatedTimeline.new(document: @document, page: 1, only: "internal_notes").entries
      end
    end
  end

  describe "#total_count" do
    it "counts the list of Document::PaginatedTimeline::VersionDecorator and EditorialRemark objects when no 'only' argument is passed in" do
      timeline = Document::PaginatedTimeline.new(document: @document, page: 1)
      assert_equal 11, timeline.total_count
    end

    it "counts the total EditorialRemark objects when 'internal_notes' is passed into the 'only' argument" do
      timeline = Document::PaginatedTimeline.new(document: @document, page: 1, only: "internal_notes")
      assert_equal 3, timeline.total_count
    end

    it "counts the total Document::PaginatedTimeline::VersionDecorator objects when 'history' is passed into the 'only' argument" do
      timeline = Document::PaginatedTimeline.new(document: @document, page: 1, only: "history")
      assert_equal 8, timeline.total_count
    end
  end

  describe "#only" do
    it "is the 'only' constructor argument" do
      timeline = Document::PaginatedTimeline.new(document: @document, page: 1)
      assert_nil timeline.only

      timeline = Document::PaginatedTimeline.new(document: @document, page: 1, only: "history")
      assert_equal "history", timeline.only

      timeline = Document::PaginatedTimeline.new(document: @document, page: 1, only: "internal_notes")
      assert_equal "internal_notes", timeline.only
    end
  end

  it "implements methods required by Kaminari for pagination" do
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

  describe "filtering entries" do
    let(:entries_for_newer_editions) do
      2.times.map do
        stub("entry", is_for_newer_edition?: true, is_for_current_edition?: false, is_for_older_edition?: false)
      end
    end

    let(:entries_for_current_edition) do
      4.times.map do
        stub("entry", is_for_newer_edition?: false, is_for_current_edition?: true, is_for_older_edition?: false)
      end
    end

    let(:entries_for_older_editions) do
      3.times.map do
        stub("entry", is_for_newer_edition?: false, is_for_current_edition?: false, is_for_older_edition?: true)
      end
    end

    let(:all_entries) do
      [*entries_for_newer_editions, *entries_for_current_edition, *entries_for_older_editions]
    end

    let(:timeline) { Document::PaginatedTimeline.new(document: @document, page: 1) }

    before do
      timeline.stubs(:entries).returns(all_entries)
    end

    describe "#entries_on_newer_editions" do
      it "returns entries on newer editions than the one passed in" do
        assert_equal entries_for_newer_editions, timeline.entries_on_newer_editions(@first_edition)
      end

      it "calls the entries with the expected edition" do
        all_entries.each do |entry|
          entry.expects(:is_for_newer_edition?).with(@first_edition)
        end

        timeline.entries_on_newer_editions(@first_edition)
      end
    end

    describe "#entries_on_current_edition" do
      it "returns entries for the edition passed in" do
        assert_equal entries_for_current_edition, timeline.entries_on_current_edition(@first_edition)
      end

      it "calls the entries with the expected edition" do
        all_entries.each do |entry|
          entry.expects(:is_for_current_edition?).with(@first_edition)
        end

        timeline.entries_on_current_edition(@first_edition)
      end
    end

    describe "#entries_on_previous_editions" do
      it "returns entries on previous editions" do
        assert_equal entries_for_older_editions, timeline.entries_on_previous_editions(@newest_edition)
      end

      it "calls the entries with the expected edition" do
        all_entries.each do |entry|
          entry.expects(:is_for_older_edition?).with(@first_edition)
        end

        timeline.entries_on_previous_editions(@first_edition)
      end
    end
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
      @editorial_remark1 = create(:editorial_remark, edition: @first_edition, author: @user2, body: "This is terrible. Make it better!")
      some_time_passes
      @first_edition.reject!
    end

    some_time_passes

    acting_as(@user) do
      @first_edition.update!(body: "New and improved")
      some_time_passes
      @editorial_remark2 = create(:editorial_remark, edition: @first_edition, author: @user, body: "I've made it better.")
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
      @editorial_remark3 = create(:editorial_remark, edition: @first_edition, author: @user, body: "Drafted to include new changes.")
    end
  end

  def mock_pagination(per_page:, &block)
    Document::PaginatedTimelineQuery.stub_const(:PER_PAGE, per_page, &block)
  end

  def some_time_passes
    Timecop.travel rand(1.hour..1.week).from_now
  end
end
