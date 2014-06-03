require 'sidekiq/testing'

Around("@without-delay, @not-quite-as-fake-search") do |_, block|
  Sidekiq::Testing.inline! do
    block.call
  end
end
