require "sidekiq/testing/inline"
require_relative "../../test/support/sidekiq_test_helpers"

World(SidekiqTestHelpers)

Around("@without-delay or @not-quite-as-fake-search") do |_scenario, block|
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
