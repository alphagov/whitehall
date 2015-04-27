# Turn on temporary feature-flag for future-policies feature during selected tests
Around("@future-policies") do |scenario, block|
  FeatureFlag.find_or_create_by(key: 'future_policies')
  FeatureFlag.set('future_policies', true)
  block.call
end
