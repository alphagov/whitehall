Given /^"([^"]*)" submitted "([^"]*)" with body "([^"]*)"$/ do |author, title, body|
  Given %{I am logged in as "#{author}"}
  And %{I visit the new policy page}
  And %{I write and save a policy called "#{title}" with body "#{body}"}
  And %{I submit the policy for the second set of eyes}
end

Then /^the policy "([^"]*)" should( not)? be visible to the public$/ do |policy_name, invert|
  visit policies_path
  published_policy_selector = ["#published_policies .policy .name", :text => policy_name]
  if invert.nil?
    assert page.has_css?(*published_policy_selector)
  else
    assert page.has_no_css?(*published_policy_selector)
  end
end