require 'sync_checker'

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

  def self.enqueue(item)
    check_class = check_class_for(item)
    return if check_class.nil?

    item_id = item_id_for(item)
    perform_in(5.minutes, check_class, item_id)
  end

  def self.check_class_for(item)
    name = "SyncChecker::Formats::#{item.class.name}Check"
    begin
      name.constantize
    rescue NameError
      nil
    end
  end

  def self.item_id_for(item)
    if item.is_a? Edition
      item.document_id
    else
      item.id
    end
  end
end
