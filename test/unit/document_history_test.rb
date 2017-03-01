require 'test_helper'

class DocumentHistoryTest < ActiveSupport::TestCase
  test "#changes on the first public edition uses the edition's change note if present" do
    edition  = create(:published_edition, change_note: "Some changes")
    history  = DocumentHistory.new(edition.document)

    assert_history_equal [[edition.public_timestamp, 'Some changes']], history
  end

  test "#changes on the first public edition uses the default change note if the edition does not have one" do
    edition  = create(:published_edition, change_note: nil)
    history  = DocumentHistory.new(edition.document)

    assert_history_equal [[edition.public_timestamp, 'First published.']], history
  end

  test "#changes on the first public edition uses the first_published_at timestamp to account for discrepancies with public_timestamp" do
    edition  = create(:published_edition, first_published_at: 4.days.ago, minor_change: false)
    history  = DocumentHistory.new(edition.document)

    assert_history_equal [[4.days.ago, edition.change_note]], history
  end

  test "#changes on a consultation derives the timestamp from the consultation opening time" do
    opening_at = 1.day.from_now
    edition  = create(:draft_consultation, opening_at: opening_at, closing_at: 2.days.from_now)
    EditionForcePublisher.new(edition).perform!
    edition.reload
    history  = DocumentHistory.new(edition.document)

    assert_equal opening_at, history.first.public_timestamp
  end

  test "#changes returns change history for all historic editions, excluding those with minor changes" do
    original_edition = Timecop.travel(3.days.ago) { create(:superseded_edition, first_published_at: Time.zone.now, change_note: nil) }
    document         = original_edition.document
    new_edition_1    = Timecop.travel(2.days.ago) { create(:superseded_edition, document: document, published_major_version: 2, published_minor_version: 0, major_change_published_at: Time.zone.now, change_note: "some changes") }
    new_edition_2    = Timecop.travel(2.days.ago) { create(:published_edition,  document: document, published_major_version: 2, published_minor_version: 1, major_change_published_at: Time.zone.now, minor_change: true) }
    new_edition_3    = Timecop.travel(1.day.ago)  { create(:published_edition,  document: document, published_major_version: 3, published_minor_version: 0, major_change_published_at: Time.zone.now, change_note: "more changes") }
    history          = DocumentHistory.new(document)

    expected = [
      [1.day.ago, 'more changes'],
      [2.day.ago, 'some changes'],
      [3.day.ago, 'First published.']
    ]

    assert_history_equal expected, history
  end

  test '#changes handles the fact that first_published_at might be changed in later editions' do
    original_edition = create(:superseded_edition, first_published_at: 3.days.ago, change_note: nil)
    document         = original_edition.document
    updated_published_time = 6.days.ago
    Timecop.travel(1.day) do
      new_edition_1    = create(:superseded_edition, document: document, first_published_at: updated_published_time, published_major_version: 1, published_minor_version: 1, minor_change: true)
    end
    history          = DocumentHistory.new(document)

    assert_history_equal [[updated_published_time, 'First published.']], history
  end

  test "the first historic edition is always included, even if it is a minor change (i.e. broken data)" do
    edition  = create(:published_edition, minor_change: true, change_note: nil)
    history  = DocumentHistory.new(edition.document)

    assert_history_equal [[edition.public_timestamp, 'First published.']], history
  end

  test "a document with no public editions returns an empty history" do
    draft_document = create(:draft_edition).document
    history        = DocumentHistory.new(draft_document)

    assert history.empty?
    assert_equal 0, history.size
  end

  test "#most_recent change returns the timestamp of the most recently published edition" do
    original_edition = Timecop.travel(3.days.ago) { create(:superseded_edition, first_published_at: Time.zone.now, change_note: nil) }
    document         = original_edition.document
    new_edition_1    = Timecop.travel(2.days.ago) { create(:superseded_edition, document: document, published_major_version: 2, published_minor_version: 0, major_change_published_at: Time.zone.now, change_note: "some changes") }
    new_edition_2    = Timecop.travel(1.days.ago) { create(:published_edition,  document: document, published_major_version: 3, published_minor_version: 0, major_change_published_at: Time.zone.now, change_note: "more changes") }
    new_edition_2    = create(:published_edition,  document: document, published_major_version: 2, published_minor_version: 1, minor_change: true)
    history          = DocumentHistory.new(document)

    assert_equal 1.day.ago, history.most_recent_change
  end

  test '#newly_published? returns true when there has only been one published edition' do
    document  = create(:published_edition).document
    assert DocumentHistory.new(document).newly_published?

    create(:superseded_edition, document: document)
    refute DocumentHistory.new(document).newly_published?
  end

  test 'withdrawn documents still get a history' do
    document = create(:withdrawn_edition, first_published_at: 2.days.ago).document
    history = DocumentHistory.new(document)

    assert_history_equal [[2.days.ago, 'change-note']], history
  end

private

  def assert_history_equal(expected, history)
    assert_equal expected, history.collect {|change| [change.public_timestamp, change.note] }
  end
end
