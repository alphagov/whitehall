class SyncCheckWorker < WorkerBase
  sidekiq_options queue: :sync_checks

  def perform(check_class, id)
    check_class = check_class.constantize if check_class.is_a? String

    item = check_class.scope_with_ids(id).first
    return if item.nil?

    results = []

    document_check = check_class.new(item)
    request = SyncChecker::RequestQueue.new(document_check, results)
    hydra = Typhoeus::Hydra.new
    request.requests.each { |req| hydra.queue(req) }
    hydra.run

    results.compact!
    results = nil if results.empty?

    SyncCheckResult.record(check_class, item.id, results)
  end
end
