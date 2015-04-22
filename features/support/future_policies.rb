# Turn on temporary feature-flag for future-policies feature during selected tests
Around("@future-policies") do |scenario, block|
  future_policies_setting = SitewideSetting.on?('future_policies')
  SitewideSetting.set('future_policies', false)
  block.call
  SitewideSetting.set('future_policies', future_policies_setting)
end
