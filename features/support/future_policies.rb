# Turn on temporary feature-flag for future-policies feature during selected tests
Around("@future-policies") do |scenario, block|
  current_future_policy_env = ENV['ENABLE_FUTURE_POLICIES']
  ENV['ENABLE_FUTURE_POLICIES'] = "true"
  block.call
  ENV['ENABLE_FUTURE_POLICIES'] = current_future_policy_env
end
