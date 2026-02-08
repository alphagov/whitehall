require "govuk_sidekiq/testing"
require "sidekiq/api"

module SidekiqTestHelpers
  def with_real_sidekiq
    Sidekiq::Testing.disable! do
      Sidekiq.configure_client do |config|
        config.redis = { db: parallel_test_runner_number }
      end

      Sidekiq::ScheduledSet.new.clear

      yield
    end
  end

private

  def parallel_test_runner_number
    return ENV["TEST_ENV_NUMBER"].to_i if ENV["TEST_ENV_NUMBER"].to_s.match?(/\A\d+\z/)
    return ENV["EXECUTOR_NUMBER"].to_i if ENV["EXECUTOR_NUMBER"].to_s.match?(/\A\d+\z/)

    current_database = ActiveRecord::Base.connection.current_database
    return Regexp.last_match(1).to_i if current_database&.match(/(\d+)\z/)
    return Regexp.last_match(1).to_i if current_database&.match(/_executor_(\d+)_/)

    0
  end
end
