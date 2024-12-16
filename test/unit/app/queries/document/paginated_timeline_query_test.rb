require "test_helper"

class Document::PaginatedTimelineQueryTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  before do
    @user = create(:departmental_editor)
    @user2 = create(:departmental_editor)
    seed_document_event_history
  end

  describe "#raw_entries" do
    it "returns an array of raw entries" do
      query = Document::PaginatedTimelineQuery.new(document: @document, page: 1)
      assert_equal %w[Version EditorialRemark].to_set,
                   query.raw_entries.map(&:model).to_set
    end

    it "returns an array of raw entries ordered newest first (reverse chronological order)" do
      query = Document::PaginatedTimelineQuery.new(document: @document, page: 1)
      entry_timestamps = query.raw_entries.map(&:created_at)
      assert_equal entry_timestamps.sort.reverse, entry_timestamps
    end

    it "paginates correctly" do
      page1_query = Document::PaginatedTimelineQuery.new(document: @document, page: 1)
      page2_query = Document::PaginatedTimelineQuery.new(document: @document, page: 2)

      assert_equal page1_query.raw_entries.count, 10
      assert_equal page2_query.raw_entries.count, 1
    end

    it "returns only `EditorialRemarks` when the only argument is set to `internal_notes`" do
      query = Document::PaginatedTimelineQuery.new(document: @document, page: 1, only: "internal_notes")
      assert_equal %w[EditorialRemark].to_set,
                   query.raw_entries.map(&:model).to_set
    end

    it "returns only `Versions` when the only argument is set to `history`" do
      query = Document::PaginatedTimelineQuery.new(document: @document, page: 1, only: "history")
      assert_equal %w[Version].to_set,
                   query.raw_entries.map(&:model).to_set
    end
  end

  describe "#total_count" do
    it "returns a count of all the results" do
      query = Document::PaginatedTimelineQuery.new(document: @document, page: 1)

      assert_equal query.total_count, 11
    end

    it "returns a count of all the results when the only argument is set to `internal_notes`" do
      query = Document::PaginatedTimelineQuery.new(document: @document, page: 1, only: "internal_notes")

      assert_equal query.total_count, 3
    end

    it "returns a count of all the results when the only argument is set to `history`" do
      query = Document::PaginatedTimelineQuery.new(document: @document, page: 1, only: "history")

      assert_equal query.total_count, 8
    end
  end

  describe "#remarks" do
    it "returns all the remarks keyed by ID" do
      query = Document::PaginatedTimelineQuery.new(document: @document, page: 1)
      expected_remarks = {
        @editorial_remark1.id => @editorial_remark1,
        @editorial_remark2.id => @editorial_remark2,
        @editorial_remark3.id => @editorial_remark3,
      }

      assert_equal query.remarks, expected_remarks
    end
  end

  describe "#versions" do
    it "returns all the versions, presented as VersionDecorator items" do
      page1_query = Document::PaginatedTimelineQuery.new(document: @document, page: 1)
      page2_query = Document::PaginatedTimelineQuery.new(document: @document, page: 2)

      versions = @document.edition_versions.where.not(state: "superseded")
      version_presenter_mocks = []

      versions.each do |version|
        version_decorator_mock = mock("VersionDecorator", id: version.id)
        VersionDecorator.stubs(:new).with { |v, **_args|
          v.id == version.id
        }.returns(version_decorator_mock)
        version_presenter_mocks.push(version_presenter_mock)
      end

      all_versions = [*page1_query.versions, *page2_query.versions]

      expected_versions = version_presenter_mocks.index_by(&:id)

      assert_equal all_versions.count, versions.count
      assert_equal all_versions.to_h, expected_versions
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

  def some_time_passes
    Timecop.travel rand(1.hour..1.week).from_now
  end
end
