require 'test_helper'

class PolicySearchIndexObserverTest < ActiveSupport::TestCase
  test 'after publishing a policy, it requests to reindex all related editions for that policy later' do
    policy = create(:submitted_policy)

    PolicySearchIndexObserver::ReindexRelatedEditions.expects(:later).with(policy)

    policy.publish_as(create(:departmental_editor))
  end

  test 'after unpublishing a policy, it requests to reindex all related editions for that policy later' do
    policy = create(:published_policy)

    PolicySearchIndexObserver::ReindexRelatedEditions.expects(:later).with(policy)
    policy.unpublishing = build(:unpublishing)
    policy.unpublish_as(create(:gds_editor))
  end

  test 'ReindexRelatedEditions.later enqueues a job for the supplied policy onto the rummager work queue' do
    policy = create(:published_policy)

    job = PolicySearchIndexObserver::ReindexRelatedEditions.new(policy.id)
    PolicySearchIndexObserver::ReindexRelatedEditions.expects(:new).with(policy.id).returns(job)
    Delayed::Job.expects(:enqueue).with(job, queue: Whitehall.rummager_work_queue_name)

    PolicySearchIndexObserver::ReindexRelatedEditions.later(policy)
  end

  test 'ReindexRelatedEditions#perform reindexes all published editions that are related to the policy' do
    policy = create(:submitted_policy)
    related_editions = mock('related editions')
    related_editions.expects(:reindex_all)
    policy.stubs(:published_related_editions).returns(related_editions)
    Policy.stubs(:find).with(policy.id).returns(policy)

    PolicySearchIndexObserver::ReindexRelatedEditions.new(policy.id).perform
  end

  test 'ReindexRelatedEditions#perform fails if the supplied policy cannot be found' do
    job = PolicySearchIndexObserver::ReindexRelatedEditions.new(1000)
    assert_raise(ActiveRecord::RecordNotFound) { job.perform }
  end
end
