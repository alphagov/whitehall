Given /^a policy area called "([^"]*)" with description "([^"]*)"$/ do |name, description|
  create(:policy_area, name: name, description: description)
end

When /^I create a new policy area "([^"]*)" with description "([^"]*)"$/ do |name, description|
  visit admin_root_path
  click_link "Policy areas"
  click_link "Create Policy Area"
  fill_in "Name", with: name
  fill_in "Description", with: description
  click_button "Save"
end

When /^I edit the policy area "([^"]*)" to have description "([^"]*)"$/ do |name, description|
  visit admin_root_path
  click_link "Policy areas"
  click_link name
  fill_in "Description", with: description
  click_button "Save"
end

Then /^I should see the "([^"]*)" policy area description is "([^"]*)"$/ do |name, description|
  visit policy_areas_path
  click_link name
  assert page.has_css?(".description", text: description)
end

Then /^I should see in the admin the "([^"]*)" policy area description is "([^"]*)"$/ do |name, description|
  visit admin_policy_areas_path
  assert page.has_css?(".name", text: name)
  assert page.has_css?(".description", text: description)
end

Then /^I should be able to delete the policy area "([^"]*)"$/ do |name|
  visit admin_policy_areas_path
  click_link name
  click_button 'Delete'
end

Given /^the policy area "([^"]*)" contains some policies$/ do |name|
  documents = Array.new(5) { build(:published_policy) } + Array.new(2) { build(:draft_policy) }
  create(:policy_area, name: name, documents: documents)
end

Given /^two policy areas "([^"]*)" and "([^"]*)" exist$/ do |first_policy_area, second_policy_area|
  create(:policy_area, name: first_policy_area)
  create(:policy_area, name: second_policy_area)
end

Given /^other policy areas also have policies$/ do
  create(:policy_area, documents: [build(:published_policy)])
  create(:policy_area, documents: [build(:published_policy)])
end

When /^I visit the list of policy areas$/ do
  visit policy_areas_path
end

When /^I visit the "([^"]*)" policy area$/ do |name|
  policy_area = PolicyArea.find_by_name!(name)
  visit policy_area_path(policy_area)
end

When /^I set the order of the policies in the "([^"]*)" policy area to:$/ do |name, table|
  policy_area = PolicyArea.find_by_name!(name)
  visit edit_admin_policy_area_path(policy_area)
  table.rows.each_with_index do |(policy_name), index|
    fill_in policy_name, with: index
  end
  click_button "Save"
end

When /^I set the featured policies in the "([^"]*)" policy area to:$/ do |name, table|
  policy_area = PolicyArea.find_by_name!(name)
  visit edit_admin_policy_area_path(policy_area)
  table.rows.each_with_index do |(policy_name), index|
    policy = Policy.find_by_title(policy_name)
    within record_css_selector(policy) do
      check "Featured?"
    end
  end
  click_button "Save"
end

Then /^I should see the featured policies in the "([^"]*)" policy area are:$/ do |name, expected_table|
  policy_area = PolicyArea.find_by_name!(name)
  visit policy_area_path(policy_area)
  rows = find("ul.featured.policies").all('li')
  table = rows.map { |r| r.all('a').map { |c| c.text.strip } }
  expected_table.diff!(table)
end

Then /^I should see the order of the policies in the "([^"]*)" policy area is:$/ do |name, expected_table|
  policy_area = PolicyArea.find_by_name!(name)
  visit policy_area_path(policy_area)
  rows = find("#policies ul.policies").all('li')
  table = rows.map { |r| r.all('a').map { |c| c.text.strip } }
  expected_table.diff!(table)
end

Then /^I should only see published policies belonging to the "([^"]*)" policy area$/ do |name|
  policy_area = PolicyArea.find_by_name!(name)
  documents = records_from_elements(Document, page.all(".document"))
  assert documents.all? { |document| policy_area.documents.published.include?(document) }
end

Then /^I should see the policy areas "([^"]*)" and "([^"]*)"$/ do |first_policy_area_name, second_policy_area_name|
  first_policy_area = PolicyArea.find_by_name!(first_policy_area_name)
  second_policy_area = PolicyArea.find_by_name!(second_policy_area_name)
  assert page.has_css?(record_css_selector(first_policy_area), text: first_policy_area_name)
  assert page.has_css?(record_css_selector(second_policy_area), text: second_policy_area_name)
end

Then /^I should see links to the "([^"]*)" and "([^"]*)" policy areas$/ do |policy_area_1_name, policy_area_2_name|
  policy_area_1 = PolicyArea.find_by_name!(policy_area_1_name)
  policy_area_2 = PolicyArea.find_by_name!(policy_area_2_name)
  assert page.has_css?("a[href='#{policy_area_path(policy_area_1)}']", text: policy_area_1_name)
  assert page.has_css?("a[href='#{policy_area_path(policy_area_2)}']", text: policy_area_2_name)
end