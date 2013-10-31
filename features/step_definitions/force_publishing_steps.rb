When /^another editor retrospectively approves the "([^"]*)" policy$/ do |policy_title|
  user = create(:departmental_editor, name: "Other editor")
  login_as user
  visit admin_editions_path(state: :published)
  click_link policy_title
  click_button "Looks good"
end

Then /^the "([^"]*)" policy should not be flagged as force\-published any more$/ do |policy_title|
  visit admin_editions_path(state: :published)
  policy = Policy.find_by_title(policy_title)
  assert page.has_css? record_css_selector(policy)
  assert page.has_no_css?(record_css_selector(policy) + ".force_published")
end

Then(/^the policy "([^"]*)" should have a force publish reason$/) do |policy_title|
  policy = Policy.find_by_title(policy_title)
  ensure_path(admin_edition_path(policy))
  assert page.has_content?('Force published: because')
end
