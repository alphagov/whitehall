require 'sidekiq/testing/inline'
require_relative '../../test/support/sidekiq_test_helpers'

include SidekiqTestHelpers

Around("@without-delay, @not-quite-as-fake-search") do |_scenario, block|
  Sidekiq::Testing.inline! do
    block.call
  end
end

Around("@disable-sidekiq-test-mode") do |_scenario, block|
  with_real_sidekiq do
    block.call
  end
end
