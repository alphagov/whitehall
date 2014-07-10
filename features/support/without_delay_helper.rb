require 'sidekiq/testing'

Around("@without-delay, @not-quite-as-fake-search") do |scenario, block|
  Sidekiq::Testing.inline! do
    block.call
  end
end

Around("@disable-sidekiq-test-mode") do |scenario, block|
  Sidekiq::Testing.disable! do
    Sidekiq::ScheduledSet.new.clear
    block.call
  end
end
