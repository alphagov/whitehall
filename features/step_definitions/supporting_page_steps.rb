When /^I add a supporting page "([^"]*)" to the "([^"]*)" policy$/ do |supporting_title, policy_title|
  policy = Policy.find_by_title!(policy_title)
  visit admin_edition_path(policy)
  click_link "Add supporting page"
  fill_in "Title", with: supporting_title
  fill_in "Summary", with: "Supportive summary"
  fill_in "Body", with: "Some supporting information"
  click_button "Save"
end

Then /^I should see in the admin list of (draft|published) documents that "([^"]*)" has supporting page "([^"]*)"$/ do |state, title, supporting_page_title|
  visit admin_editions_path(state: state)
  edition = Edition.find_by_title!(title)
  within(record_css_selector(edition)) do
    assert has_css?(".supporting_pages", text: /#{supporting_page_title}/)
  end
end

Then(/^I should see on the (published|preview) policy page that "(.*?)" has supporting page "(.*?)"$/) do |version, policy_title, supporting_page_title|
  policy = Policy.find_by_title(policy_title).latest_edition

  options = { preview: policy.id } if version == 'preview'
  visit policy_supporting_pages_path(policy.document, options)
  assert page.has_content?(supporting_page_title)
end
