When /^I draft a new specialist guide "([^"]*)"$/ do |title|
  begin_drafting_document type: 'specialist_guide', title: title
  click_button "Save"
end

When /^I draft a new specialist guide "([^"]*)" in the "([^"]*)" and "([^"]*)" topics$/ do |title, first_topic, second_topic|
  begin_drafting_document type: 'specialist_guide', title: title
  check "Create a page for each top level heading?"
  select first_topic, from: "Topics"
  select second_topic, from: "Topics"
  click_button "Save"
end

Given /^I start drafting a new specialist guide$/ do
  begin_drafting_document type: 'specialist_guide', title: "Specialist Guide"
end

When /^I select an image for the specialist guide$/ do
  within ".images" do
    attach_file "File", Rails.root.join("features/fixtures/minister-of-soul.jpg")
  end
end

Then /^I should be able to select another image for the specialist guide$/ do
  assert_equal 2, page.all(".images input[type=file]").length
end

When /^I select an attachment for the specialist guide$/ do
  within ".attachments" do
    attach_file "File", Rails.root.join("features/fixtures/attachment.pdf")
  end
end

Then /^I should be able to select another attachment for the specialist guide$/ do
  assert_equal 2, page.all(".attachments input[type=file]").length
end
