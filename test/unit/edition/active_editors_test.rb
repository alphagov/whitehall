require "test_helper"

class Edition::ActiveEditorsTest < ActiveSupport::TestCase
  test "can record editing intent" do
    user = create(:writer)
    edition = create(:edition)
    edition.open_for_editing_as(user)
    Timecop.travel(1.minute.from_now)
    assert_equal [user], edition.recent_edition_openings.map(&:editor)
  end

  test "recording editing intent for a user who's already editing just updates the timestamp" do
    user = create(:writer)
    edition = create(:edition)
    edition.open_for_editing_as(user)
    Timecop.travel(1.minute.from_now)
    assert_difference "edition.recent_edition_openings.count", 0 do
      edition.open_for_editing_as(user)
    end
    assert_equal user, edition.recent_edition_openings.first.editor
    assert_equal Time.zone.now.to_s(:rfc822), edition.recent_edition_openings.first.created_at.in_time_zone.to_s(:rfc822)
  end

  test "can check exclude a given editor from the list of recent edition openings" do
    user_1 = create(:writer)
    edition = create(:edition)
    edition.open_for_editing_as(user_1)
    Timecop.travel(1.minute.from_now)
    user_2 = create(:writer)
    edition.open_for_editing_as(user_2)
    assert_equal [user_1], edition.recent_edition_openings.except_editor(user_2).map(&:editor)
  end

  test "editors considered active for up to 2 hours" do
    user = create(:writer)
    edition = create(:edition)
    edition.open_for_editing_as(user)
    Timecop.travel((1.hour + 59.minutes).from_now)
    assert_equal [user], edition.active_edition_openings.map(&:editor)
    Timecop.travel((1.minute + 1.second).from_now)
    assert_equal [], edition.active_edition_openings
  end

  test "#save_as removes all RecentEditionOpenings for the specified editor" do
    user = create(:writer)
    edition = create(:edition)
    edition.open_for_editing_as(user)
    assert_difference "edition.recent_edition_openings.count", -1 do
      edition.save_as(user)
    end
  end

  test "RecentEditionOpening#expunge! deletes entries more than 2 hours old" do
    edition = create(:edition)
    create(:recent_edition_opening, editor: create(:author), edition: edition, created_at: 2.hours.ago + 1.second)
    create(:recent_edition_opening, editor: create(:author), edition: edition, created_at: 2.hours.ago)
    create(:recent_edition_opening, editor: create(:author), edition: edition, created_at: 2.hours.ago - 1.second)
    assert_equal 3, RecentEditionOpening.count
    RecentEditionOpening.expunge!
    assert_equal 2, RecentEditionOpening.count
  end
end
