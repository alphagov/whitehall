# Turn on temporary feature-flag for future-policies feature during selected tests
Around("@future-policies") do |scenario, block|
  begin
    current_value = FeatureFlag.enabled?('future-policies')
    FeatureFlag.find_or_create_by(key: 'future_policies')
    FeatureFlag.set('future_policies', true)
    block.call
  ensure
    FeatureFlag.set('future_policies', current_value)
  end
end
