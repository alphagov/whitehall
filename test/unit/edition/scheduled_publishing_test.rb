require "test_helper"

class Edition::ScheduledPublishingTest < ActiveSupport::TestCase
  test "can find editions due for publication" do
    due_in_one_day = create(:edition, :scheduled, scheduled_publication: 1.day.from_now)
    due_in_two_days = create(:edition, :scheduled, scheduled_publication: 2.days.from_now)
    already_published = create(:edition, :published, scheduled_publication: 1.day.from_now)
    Timecop.freeze 1.day.from_now do
      assert_equal [due_in_one_day], Edition.due_for_publication
    end
    Timecop.freeze 2.days.from_now do
      assert_equal [due_in_one_day, due_in_two_days], Edition.due_for_publication
    end
  end

  test "can find editions due for publication within a certain time span" do
    due_in_one_day = create(:edition, :scheduled, scheduled_publication: 1.day.from_now)
    due_in_two_days = create(:edition, :scheduled, scheduled_publication: 2.days.from_now)
    assert_equal [due_in_one_day], Edition.due_for_publication(1.day)
    assert_equal [due_in_one_day, due_in_two_days], Edition.due_for_publication(2.days)
  end

  test ".scheduled_for_publication_as returns edition if edition is scheduled" do
    edition = create(:scheduled_publication, scheduled_publication: 1.day.from_now)
    assert_equal edition, Publication.scheduled_for_publication_as(edition.document.to_param)
  end

  test ".scheduled_for_publication_as returns nil if edition is not scheduled" do
    edition = create(:draft_publication, scheduled_publication: 1.day.from_now)
    assert_nil Edition.scheduled_for_publication_as(edition.document.to_param)
  end

  test ".scheduled_for_publication_as returns nil if document is unknown" do
    assert_nil Edition.scheduled_for_publication_as('unknown')
  end
end
