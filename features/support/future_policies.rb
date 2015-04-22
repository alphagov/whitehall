# Turn on temporary feature-flag for future-policies feature during selected tests
Around("@future-policies") do |scenario, block|
  future_policies_setting = FeatureFlag.enabled?('future_policies')
  FeatureFlag.find_or_create_by(key: 'future_policies')
  FeatureFlag.set('future_policies', true)
  block.call
  FeatureFlag.set('future_policies', future_policies_setting)
end
