class ReindexRelatedEditions < Struct.new(:policy_id)
  def policy
    Policy.find(policy_id)
  end
  def perform
    policy.published_related_editions.reindex_all
  end
  def self.later(policy)
    job = new(policy.id)
    Delayed::Job.enqueue job, queue: Whitehall.rummager_work_queue_name
  end
end
