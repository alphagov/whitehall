require "govuk_sidekiq/testing"
require "sidekiq/api"

module SidekiqTestHelpers
  def with_real_sidekiq(worker_name = "whitehall-test")
    Sidekiq::Testing.disable! do
      Sidekiq.configure_client do |config|
        config.redis = { namespace: worker_name }
      end

      Sidekiq::ScheduledSet.new.clear

      yield
    end
  end
end
