require 'test_helper'

class EditionSchedulerTest < ActiveSupport::TestCase

  test '#perform! with a valid (submitted) schedulable edition transitions the edition' do
    edition = create(:submitted_edition, scheduled_publication: 1.day.from_now)

    assert EditionScheduler.new(edition).perform!
    assert edition.scheduled?
  end

  %w(published draft imported rejected superseded scheduled).each do |state|
    test "#{state} editions cannot be scheduled" do
      edition = create(:"#{state}_edition", scheduled_publication: 1.day.from_now)
      scheduler = EditionScheduler.new(edition)

      refute scheduler.perform!
      assert_equal state, edition.state
      assert_equal "An edition that is #{state} cannot be scheduled", scheduler.failure_reason
    end
  end

  test 'an invalid edition cannot be scheduled' do
    edition = create(:submitted_edition, scheduled_publication: 1.day.from_now)
    edition.title = nil
    scheduler = EditionScheduler.new(edition)

    refute scheduler.perform!
    refute edition.scheduled?
    assert_equal "This edition is invalid: Title can't be blank", scheduler.failure_reason
  end

  test 'an edition that does not have a scheduled_publication timestamp cannot be scheduled' do
    edition = create(:submitted_edition)
    scheduler = EditionScheduler.new(edition)

    refute scheduler.perform!
    refute edition.scheduled?
    assert_equal "This edition does not have a scheduled publication date set", scheduler.failure_reason
  end

  test 'an edition that has bad links cannot be scheduled' do
    edition = create(:submitted_edition, scheduled_publication: 1.day.from_now, body: "[Example](government/admin/editions/12324)")
    scheduler = EditionScheduler.new(edition)

    refute scheduler.perform!
    refute edition.scheduled?
    assert_equal "This edition contains bad links", scheduler.failure_reason
  end
end
