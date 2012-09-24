Given /^a published specialist guide "([^"]*)" related to published specialist guides "([^"]*)" and "([^"]*)"$/ do |title, first_related_title, second_related_title|
  first_related = create(:published_specialist_guide, title: first_related_title)
  second_related = create(:published_specialist_guide, title: second_related_title)
  guide = create(:published_specialist_guide, title: title, outbound_related_documents: [first_related.document, second_related.document], topics: [create(:topic)])
end

Given /^a published specialist guide "([^"]*)" for the organisation "([^"]*)"$/ do |title, organisation|
  organisation = create(:organisation, name: organisation)
  create(:published_specialist_guide, title: title, organisations: [organisation])
end

Given /^(\d+) published specialist guides for the organisation "([^"]*)"$/ do |count, organisation|
  organisation = create(:organisation, name: organisation)
  count.to_i.times { |i| create(:published_specialist_guide, title: "keyword-#{i}", organisations: [organisation]) }
end

When /^I draft a new specialist guide "([^"]*)"$/ do |title|
  begin_drafting_document type: 'specialist_guide', title: title
  click_button "Save"
end

When /^I draft a new specialist guide "([^"]*)" in the "([^"]*)" and "([^"]*)" topics$/ do |title, first_topic, second_topic|
  begin_drafting_document type: 'specialist_guide', title: title
  select first_topic, from: "Topics"
  select second_topic, from: "Topics"
  click_button "Save"
end

When /^I draft a new specialist guide "([^"]*)" related to the specialist guide "([^"]*)"$/ do |title, related_title|
  related_guide = SpecialistGuide.find_by_title!(related_title)
  begin_drafting_document type: 'specialist_guide', title: title
  select related_title, from: "Related guides"
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

When /^I visit the specialist guide "([^"]*)"$/ do |name|
  visit "/specialist"
  click_link name
end

When /^I visit the list of specialist guides$/ do
  visit "/specialist"
end

Then /^I can see links to the related specialist guides "([^"]*)" and "([^"]*)"$/ do |guide_1, guide_2|
  within ".related-specialist-guides" do
    assert has_css?("a", text: guide_1), "should have link to #{guide_1}"
    assert has_css?("a", text: guide_2), "should have link to #{guide_2}"
  end
end

Then /^I should be able to select another image for the specialist guide$/ do
  assert_equal 2, page.all(".images input[type=file]").length
end

When /^I select an attachment for the specialist guide$/ do
  @attachment_filename = "attachment.pdf"
  within ".attachments" do
    attach_file "File", Rails.root.join("features/fixtures", @attachment_filename)
  end
end

Then /^I should be able to select another attachment for the specialist guide$/ do
  assert_equal 2, page.all(".attachments input[type=file]").length
end

Then /^I should see in the preview that "([^"]*)" is related to the specialist guide "([^"]*)"$/ do |title, related_title|
  visit_document_preview title
  assert has_css?(".specialist_guide", text: related_title)
end

Given /^a mainstream category "([^"]*)" exists$/ do |title|
  create(:mainstream_category, title: title, identifier: "http://example.com/tags/#{title.parameterize}.json", parent_title: "Some parent")
end

Given /^a submitted specialist guide "([^"]*)" exists in the "([^"]*)" mainstream category$/ do |title, category_title|
  category = MainstreamCategory.find_by_title!(category_title)
  create(:submitted_specialist_guide, title: title, mainstream_category: category)
end

Then /^the specialist guide "([^"]*)" should be visible to the public in the mainstream category "([^"]*)"$/ do |title, category_title|
  category = MainstreamCategory.find_by_title!(category_title)
  specialist_guide = SpecialistGuide.latest_edition.find_by_title!(title)

  visit url_for(category)
  assert page.has_css?(record_css_selector(specialist_guide))
end

