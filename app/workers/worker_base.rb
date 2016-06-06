class WorkerBase
  include Sidekiq::Worker

  def self.perform_async(*args)
    args << request_header_arguments
    super(*args)
  end

  def self.perform_async_in_queue(queue, *args)
    args << request_header_arguments
    client_push('class' => self, 'args' => args, 'queue' => queue || get_sidekiq_options["queue"])
  end

  def self.request_header_arguments
    {
      request_id: GdsApi::GovukHeaders.headers[:govuk_request_id],
      authenticated_user: GdsApi::GovukHeaders.headers[:x_govuk_authenticated_user],
    }
  end
  private_class_method :request_header_arguments

  def perform(*args)
    last_arg = args.last

    if last_arg.is_a?(Hash) && last_arg.keys.include?("request_id")
      args.pop
      authenticated_user = last_arg["authenticated_user"]
      request_id = last_arg["request_id"]
    else
      authenticated_user = nil
      request_id = nil
    end

    GdsApi::GovukHeaders.set_header(:x_govuk_authenticated_user, authenticated_user)
    GdsApi::GovukHeaders.set_header(:govuk_request_id, request_id)
    call(*args)
  end
end
