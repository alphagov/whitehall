# Turn on temporary feature-flag for future-policies feature during selected tests
Around("@future-policies") do |scenario, block|
  future_policies_setting = Whitehall.future_policies_enabled
  Whitehall.future_policies_enabled = true
  block.call
  Whitehall.future_policies_enabled = future_policies_setting
end
