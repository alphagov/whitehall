require "test_helper"

class PaginatedHistoryTest < ActiveSupport::TestCase
  setup do
    @per_page = 3

    @document = create(:document)
    @first_edition = create(:draft_edition, document: @document, major_change_published_at: Time.zone.now)
    Timecop.travel 1.day.from_now
    @first_edition.submit!
    Timecop.travel 1.day.from_now
    @first_edition.versions.create!(event: "updated", state: "submitted")
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
    @first_edition.unschedule!
    Timecop.travel 1.day.from_now
    @first_edition.force_publish!

    @newest_edition = create(:draft_edition, document: @document)
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

  def mock_pagination(&block)
    Document::PaginatedHistory.stub_const(:PER_PAGE, @per_page, &block)
  end
end
