require 'govuk_sidekiq/testing'
require 'sidekiq/api'

module SidekiqTestHelpers
  def with_real_sidekiq()
    Sidekiq::Testing.disable! do
      Sidekiq.configure_client do |config|
        config.redis = { namespace: 'whitehall-test' }
      end

      Sidekiq::ScheduledSet.new.clear

      yield
    end
  end
end
