require 'sidekiq/testing'

Around("@without-delay, @not-quite-as-fake-search") do |scenario, block|
  Sidekiq::Testing.inline! do
    block.call
  end
end
