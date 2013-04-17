slugs = ["nuclear-emergency-planning-liaison-group",
"delete",
"treasure-valuation-committee",
"criminal-procedure-rule-committee",
"civil-procedure-rule-committee",
"family-procedure-rule-committee",
"quality-information-committee--2"]

slugs.each do |slug|
  group = PolicyAdvisoryGroup.find_by_slug(slug)
  puts "PolicyAdvisoryGroup: #{slug} deleted" if group && group.delete
end