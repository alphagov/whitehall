require "govuk_sidekiq/testing"
require "sidekiq/api"

module SidekiqTestHelpers
  def with_real_sidekiq
    Sidekiq::Testing.disable! do
      scheduled_set = Sidekiq::ScheduledSet.new
      scheduled_set.clear
      yield
    ensure
      scheduled_set&.clear
    end
  end
end
