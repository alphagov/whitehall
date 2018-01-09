Given(/^and the policies "(.*?)" and "(.*?)" exist$/) do |policy_name_1, policy_name_2|
  publishing_api_has_policies([policy_name_1, policy_name_2])
end

When(/^I feature the policies "(.*?)" and "(.*?)" for "(.*?)"$/) do |policy_name_1, policy_name_2, organisation_name|
  visit_organisation_featured_policies_admin organisation_name
  feature_policies_on_organisation [policy_name_1, policy_name_2]
end

When(/^I stop featuring the polices "(.*?)" for "(.*?)"$/) do |policy_name, organisation_name|
  visit_organisation_featured_policies_admin organisation_name
  unfeature_organisation_policy(policy_name)
end

Then(/^there should be no featured policies on the home page of "(.*?)"$/) do |organisation_name|
  visit_organisation organisation_name
  check_no_featured_policies
end

When(/^I order the featured policies in the "(.*?)" organisation as:$/) do |organisation_name, table|
  visit_organisation_featured_policies_admin organisation_name
  order_features_from(table)
end

Then(/^I should see the featured policies in the "(.*?)" organisation are:$/) do |organisation_name, table|
  visit_organisation organisation_name
  check_policies_are_featured_in_order(table)
end
