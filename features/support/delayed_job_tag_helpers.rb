require Rails.root.join('test/support/delayed_job_test_helpers.rb')

Around("@without-delay, @not-quite-as-fake-search") do |scenario, block|
  DelayedJobTestHelpers.without_delay! do
    block.call
  end
end
