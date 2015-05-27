require 'test_helper'

  module DataHygiene
  class PolicyPublicationHistoryWriterTest < ActiveSupport::TestCase
    setup do
      create(:gds_team_user)
      @policy = build_policy_with_history
      @publication = build_policy_publication
    end

    test "updates the publication such that its history replicates that of the originating policy, plus history for it's own creation" do
      history_writer = PolicyPublicationHistoryWriter.new(publication, policy)
      history_writer.rewrite_history!

      expected_history = [
        [4.days.ago, 'Policy document... preserved in a different format'],
        [8.months.ago, 'More changes were made.'],
        [9.months.ago, 'Some changes were made.'],
        [1.year.ago, 'First published.']
      ]

      assert_equal expected_history,
        publication.reload.change_history.changes.map(&:to_a)
    end

    test "handles publications that have had minor changes since initial publication" do
      make_minor_changes_to_publication

      history_writer = PolicyPublicationHistoryWriter.new(publication, policy)
      history_writer.rewrite_history!

      expected_history = [
        [4.days.ago, 'Policy document... preserved in a different format'],
        [8.months.ago, 'More changes were made.'],
        [9.months.ago, 'Some changes were made.'],
        [1.year.ago, 'First published.']
      ]

      assert_equal expected_history,
        publication.reload.change_history.changes.map(&:to_a)
    end

    test "handles withdrawn publications" do
      withdraw_the_publication

      history_writer = PolicyPublicationHistoryWriter.new(publication, policy)
      history_writer.rewrite_history!

      expected_history = [
        [4.days.ago, 'Policy document... preserved in a different format'],
        [8.months.ago, 'More changes were made.'],
        [9.months.ago, 'Some changes were made.'],
        [1.year.ago, 'First published.']
      ]

      latest_edition = publication.document.latest_edition
      assert latest_edition.withdrawn?
      assert unpublishing = latest_edition.unpublishing
      assert_equal 'Published by mistake', unpublishing.explanation
      assert_equal expected_history,
        publication.reload.change_history.changes.map(&:to_a)
    end

    test "resets first_published_at to match the original policy" do
      change_first_published_at

      history_writer = PolicyPublicationHistoryWriter.new(publication, policy)
      history_writer.rewrite_history!

      expected_history = [
        [4.days.ago, 'Policy document... preserved in a different format'],
        [8.months.ago, 'More changes were made.'],
        [9.months.ago, 'Some changes were made.'],
        [1.year.ago, 'First published.']
      ]

      assert_equal expected_history,
        publication.reload.change_history.changes.map(&:to_a)
    end

  private
    attr_reader :policy, :publication

    def user
      @user ||= create(:gds_editor)
    end

    def build_policy_with_history
      initial_edition = Timecop.travel 1.year.ago do
        create(:published_policy,
          first_published_at: Time.zone.now,
          major_change_published_at: Time.zone.now,
          change_note: nil)
      end

      minor_change = Timecop.travel 10.months.ago do
        edition = initial_edition.create_draft(user)
        edition.minor_change = true
        force_publish(edition)
        edition
      end
      first_major_change = Timecop.travel 9.months.ago do
        edition = minor_change.create_draft(user)
        edition.change_note = "Some changes were made."
        force_publish(edition)
        edition
      end
      second_major_change = Timecop.travel 8.months.ago do
        edition = first_major_change.create_draft(user)
        edition.change_note = "More changes were made."
        force_publish(edition)
        edition
      end
      Timecop.travel 7.months.ago do
        final_edition = second_major_change.create_draft(user)
        final_edition.minor_change = true
        force_publish(final_edition)
        final_edition
      end
    end

    def build_policy_publication
      Timecop.travel 4.days.ago do
        create(:published_policy_paper,
          change_note: 'Policy document... preserved in a different format',
          first_published_at: policy.first_published_at,
          major_change_published_at: Time.zone.now,
          public_timestamp: Time.zone.now)
      end
    end

    def make_minor_changes_to_publication
      minor_change = Timecop.travel 2.days.ago do
        edition = publication.create_draft(user)
        edition.minor_change = true
        force_publish(edition)
        edition
      end
      Timecop.travel 1.day.ago do
        edition = minor_change.create_draft(user)
        edition.minor_change = true
        force_publish(edition)
      end
    end

    def withdraw_the_publication
      Timecop.travel 2.days.ago do
        publication.build_unpublishing(unpublishing_reason_id: UnpublishingReason::Withdrawn.id,
                                       explanation: "Published by mistake")
        publication.archive!
      end
    end

    def change_first_published_at
      make_minor_changes_to_publication
      publication.document.latest_edition.update_column(:first_published_at, 1.week.ago)
    end
  end
end
