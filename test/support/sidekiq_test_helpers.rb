require "govuk_sidekiq/testing"
require "sidekiq/api"

module SidekiqTestHelpers
  def with_real_sidekiq
    Sidekiq::Testing.disable! do
      Sidekiq.configure_client do |config|
        # The Rails built-in test parallelization doesn't make it easy to find the worker number.
        # So here we're using the number suffixed to the Postgres database name, because that is unique for each worker.
        parallel_test_runner_number = ActiveRecord::Base.connection.current_database.split("-").last.to_i
        config.redis = { db: parallel_test_runner_number }
      end

      Sidekiq::ScheduledSet.new.clear

      yield
    end
  end
end
