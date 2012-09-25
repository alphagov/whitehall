Given /^a published detailed guide "([^"]*)" related to published detailed guides "([^"]*)" and "([^"]*)"$/ do |title, first_related_title, second_related_title|
  first_related = create(:published_detailed_guide, title: first_related_title)
  second_related = create(:published_detailed_guide, title: second_related_title)
  guide = create(:published_detailed_guide, title: title, outbound_related_documents: [first_related.document, second_related.document], topics: [create(:topic)])
end

Given /^a published detailed guide "([^"]*)" for the organisation "([^"]*)"$/ do |title, organisation|
  organisation = create(:organisation, name: organisation)
  create(:published_detailed_guide, title: title, organisations: [organisation])
end

Given /^(\d+) published detailed guides for the organisation "([^"]*)"$/ do |count, organisation|
  organisation = create(:organisation, name: organisation)
  count.to_i.times { |i| create(:published_detailed_guide, title: "keyword-#{i}", organisations: [organisation]) }
end

When /^I draft a new detailed guide "([^"]*)"$/ do |title|
  category = create(:mainstream_category)
  begin_drafting_document type: 'detailed_guide', title: title, primary_mainstream_category: category
  click_button "Save"
end

When /^I draft a new detailed guide "([^"]*)" in the "([^"]*)" and "([^"]*)" topics$/ do |title, first_topic, second_topic|
  category = create(:mainstream_category)
  begin_drafting_document type: 'detailed_guide', title: title, primary_mainstream_category: category
  select first_topic, from: "Topics"
  select second_topic, from: "Topics"
  click_button "Save"
end

When /^I draft a new detailed guide "([^"]*)" related to the detailed guide "([^"]*)"$/ do |title, related_title|
  category = create(:mainstream_category)
  related_guide = DetailedGuide.find_by_title!(related_title)
  begin_drafting_document type: 'detailed_guide', title: title, primary_mainstream_category: category
  select related_title, from: "Related guides"
  click_button "Save"
end

Given /^I start drafting a new detailed guide$/ do
  category = create(:mainstream_category)
  begin_drafting_document type: 'detailed_guide', title: "Detailed Guide", primary_mainstream_category: category
end

When /^I select an image for the detailed guide$/ do
  within ".images" do
    attach_file "File", Rails.root.join("features/fixtures/minister-of-soul.jpg")
  end
end

When /^I visit the detailed guide "([^"]*)"$/ do |name|
  visit "/specialist"
  click_link name
end

When /^I visit the list of detailed guides$/ do
  visit "/specialist"
end

Then /^I can see links to the related detailed guides "([^"]*)" and "([^"]*)"$/ do |guide_1, guide_2|
  within ".related-detailed-guides" do
    assert has_css?("a", text: guide_1), "should have link to #{guide_1}"
    assert has_css?("a", text: guide_2), "should have link to #{guide_2}"
  end
end

Then /^I should be able to select another image for the detailed guide$/ do
  assert_equal 2, page.all(".images input[type=file]").length
end

When /^I select an attachment for the detailed guide$/ do
  @attachment_filename = "attachment.pdf"
  within ".attachments" do
    attach_file "File", Rails.root.join("features/fixtures", @attachment_filename)
  end
end

Then /^I should be able to select another attachment for the detailed guide$/ do
  assert_equal 2, page.all(".attachments input[type=file]").length
end

Then /^I should see in the preview that "([^"]*)" is related to the detailed guide "([^"]*)"$/ do |title, related_title|
  visit_document_preview title
  assert has_css?(".detailed_guide", text: related_title)
end

Given /^a mainstream category "([^"]*)" exists$/ do |title|
  create(:mainstream_category, title: title, identifier: "http://example.com/tags/#{title.parameterize}.json", parent_title: "Some parent")
end

Given /^a submitted detailed guide "([^"]*)" exists in the "([^"]*)" mainstream category$/ do |title, category_title|
  category = MainstreamCategory.find_by_title!(category_title)
  create(:submitted_detailed_guide, title: title, primary_mainstream_category: category)
end

Then /^the detailed guide "([^"]*)" should be visible to the public in the mainstream category "([^"]*)"$/ do |title, category_title|
  category = MainstreamCategory.find_by_title!(category_title)
  detailed_guide = DetailedGuide.latest_edition.find_by_title!(title)

  visit url_for(category)
  assert page.has_css?(record_css_selector(detailed_guide))
end
