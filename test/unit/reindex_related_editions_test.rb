require 'test_helper'

class ReindexRelatedEditionsTest < ActiveSupport::TestCase
  test 'ReindexRelatedEditions.later enqueues a job for the supplied policy onto the rummager work queue' do
    policy = create(:published_policy)

    job = ReindexRelatedEditions.new(policy.id)
    ReindexRelatedEditions.expects(:new).with(policy.id).returns(job)
    Delayed::Job.expects(:enqueue).with(job, queue: Whitehall.rummager_work_queue_name)

    ReindexRelatedEditions.later(policy)
  end

  test '#perform reindexes all published editions that are related to the policy' do
    policy = create(:submitted_policy)
    related_editions = mock('related editions')
    related_editions.expects(:reindex_all)
    policy.stubs(:published_related_editions).returns(related_editions)
    Policy.stubs(:find).with(policy.id).returns(policy)

    ReindexRelatedEditions.new(policy.id).perform
  end

  test 'ReindexRelatedEditions#perform fails if the supplied policy cannot be found' do
    job = ReindexRelatedEditions.new(1000)
    assert_raise(ActiveRecord::RecordNotFound) { job.perform }
  end
end
