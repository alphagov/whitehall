require_relative "../../test/support/sidekiq_test_helpers"
# govuk_sidekiq/testing (required above, via sidekiq_test_helpers) forces fake
# mode as a side effect of being required, so this must run after that require
# or it gets silently overridden back to :fake.
Sidekiq.testing!(:inline)

World(SidekiqTestHelpers)

Sidekiq.logger.level = Logger::WARN

Around("@without-delay") do |_scenario, block|
  Sidekiq::Testing.inline! do
    block.call
  end
end

Around("@disable-sidekiq-test-mode") do |_scenario, block|
  with_real_sidekiq do
    block.call
  end
end

Around("@enable-sidekiq-test-mode") do |_scenario, block|
  Sidekiq::Testing.fake! do
    block.call
  end
end
