require "test_helper"

class RevalidateEditionsWorkerTest < ActiveSupport::TestCase
  test "enqueues a RevalidateEditionWorker for every Edition that isn't unpublished, superseded or deleted" do
    Sidekiq::Testing.fake! do
      # Editions that SHOULD trigger a worker
      draft = create(:draft_edition, title: "Draft")
      submitted = create(:submitted_edition, title: "Submitted")
      rejected = create(:rejected_edition, title: "Rejected")
      published = create(:published_edition, title: "Published")
      scheduled = create(:scheduled_edition, title: "Scheduled")
      force_published = create(:force_published_edition, title: "Force published")
      withdrawn = create(:withdrawn_edition, title: "Withdrawn")

      # Editions that SHOULD NOT trigger a worker
      unpublished = create(:unpublished_edition, title: "Unpublished")
      superseded = create(:superseded_edition, title: "Superseded")

      RevalidateEditionsWorker.new.perform

      enqueued_ids = RevalidateEditionWorker.jobs.map { |job| job["args"].first }

      expected_ids = [draft, submitted, rejected, published, scheduled, force_published, withdrawn].map(&:id)
      unexpected_ids = [unpublished.id, superseded.id]

      expected_ids.each do |id|
        assert_includes enqueued_ids, id, "Expected edition #{id} to be enqueued"
      end

      unexpected_ids.each do |id|
        assert_not_includes enqueued_ids, id, "Did not expect edition #{id} to be enqueued"
      end
    end
  end
end
