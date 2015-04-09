class WorkerBase
  include Sidekiq::Worker

  def self.perform_async_in_queue(queue, *args)
    client_push('class' => self, 'args' => args, 'queue' => queue)
  end
end
