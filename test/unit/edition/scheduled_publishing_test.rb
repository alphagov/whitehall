require "test_helper"

class Edition::ScheduledPublishingTest < ActiveSupport::TestCase
  test "draft, submitted or rejected edition is not valid if scheduled_publication date is sooner than the default minimum cache lifetime" do
    Edition.state_machine.states.each do |state|
      Whitehall.stubs(:default_cache_max_age).returns(15.minutes)
      edition = create(:edition, state.name, scheduled_publication: Whitehall.default_cache_max_age.from_now - 1.second + 1.minute)
      Timecop.freeze(2.minutes.from_now) do
        if [:draft, :submitted, :rejected].include?(state.name)
          refute edition.valid?, "#{state.name} edition should be invalid"
          assert edition.errors[:scheduled_publication].include?("date must be at least 15 minutes from now")
        else
          assert edition.valid?, "#{state.name} edition should be valid, but #{edition.errors.full_messages.inspect}"
        end
      end
    end
  end

  test "scheduled_publication can be in the past when rejecting" do
    edition = create(:edition, :submitted, scheduled_publication: Whitehall.default_cache_max_age.from_now)
    Timecop.freeze(Whitehall.default_cache_max_age.from_now + 1.minute) do
      assert edition.reject!
      assert edition.rejected?
      assert edition.reload.rejected?
    end
  end

  test "scheduled_publication can be in the past when unpublishing" do
    edition = create(:edition, :published, scheduled_publication: Whitehall.default_cache_max_age.from_now)
    Timecop.freeze(Whitehall.default_cache_max_age.from_now + 1.minute) do
      assert edition.unpublish!
      assert edition.draft?
      assert edition.reload.draft?
    end
  end

  test "scheduled_publication must be in the future if editing a rejected document" do
    edition = create(:edition, :rejected, scheduled_publication: Whitehall.default_cache_max_age.from_now + 1.minute)
    Timecop.freeze(Whitehall.default_cache_max_age.from_now + 2.minutes) do
      refute edition.valid?
      edition.scheduled_publication = Whitehall.default_cache_max_age.from_now
      assert edition.valid?
    end
  end

  test "is unschedulable only if scheduled" do
    Edition.state_machine.states.each do |state|
      edition = build(:edition, state.name)
      if state.name == :scheduled
        assert_equal nil, edition.reason_to_prevent_unscheduling
      else
        assert_equal "This edition is not scheduled for publication", edition.reason_to_prevent_unscheduling
      end
    end
  end

  test "unscheduling changes state to submitted, clears force publish flag and returns true on success" do
    author = build(:author)
    edition = build(:edition, :scheduled, force_published: true)
    assert edition.unschedule_as(author)
    assert_equal "submitted", edition.state
    assert_equal false, edition.force_published
  end

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
