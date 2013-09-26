Given /^a published detailed guide "([^"]*)" related to published detailed guides "([^"]*)" and "([^"]*)"$/ do |title, first_related_title, second_related_title|
  first_related = create(:published_detailed_guide, title: first_related_title)
  second_related = create(:published_detailed_guide, title: second_related_title)
  guide = create(:published_detailed_guide, title: title, outbound_related_documents: [first_related.document, second_related.document], topics: [create(:topic)])
end

Given /^a published detailed guide "([^"]*)" for the organisation "([^"]*)"$/ do |title, organisation|
  organisation = create(:organisation, name: organisation)
  create(:published_detailed_guide, title: title, organisations: [organisation])
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
  related_guide = DetailedGuide.latest_edition.find_by_title!(related_title)
  begin_drafting_document type: 'detailed_guide', title: title, primary_mainstream_category: category
  select related_title, from: "Related guides"
  click_button "Save"
end

Given /^I start drafting a new detailed guide$/ do
  category = create(:mainstream_category)
  begin_drafting_document type: 'detailed_guide', title: "Detailed Guide", primary_mainstream_category: category
end

When /^I visit the detailed guide "([^"]*)"$/ do |name|
  guide = DetailedGuide.find_by_title!(name)
  visit detailed_guide_path(guide.document)
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
    choose "Individual upload"
    attach_file "File", Rails.root.join("features/fixtures", @attachment_filename)
  end
end

Then /^I should see in the preview that "([^"]*)" is related to the detailed guide "([^"]*)"$/ do |title, related_title|
  visit_document_preview title
  assert has_css?(".detailed_guide", text: related_title)
end

Given /^a mainstream category "([^"]*)" exists$/ do |title|
  create(:mainstream_category, title: title, slug: title.parameterize, parent_title: "Some parent", parent_tag: "some/parent")
end

Given /^a submitted detailed guide "([^"]*)" exists in the "([^"]*)" mainstream category$/ do |title, category_title|
  category = MainstreamCategory.find_by_title!(category_title)
  create(:submitted_detailed_guide, title: title, primary_mainstream_category: category)
end

Then /^the detailed guide "([^"]*)" should be visible to the public in the mainstream category "([^"]*)"$/ do |title, category_title|
  category = MainstreamCategory.find_by_title!(category_title)
  detailed_guide = DetailedGuide.latest_edition.find_by_title!(title)
  visit "/browse/#{category.parent_tag}/#{category.slug}"
  assert page.has_css?(record_css_selector(detailed_guide))
end

When /^I publish a new edition of the detailed guide "([^"]*)" with a change note "([^"]*)"$/ do |guide_title, change_note|
  guide = DetailedGuide.latest_edition.find_by_title!(guide_title)
  visit admin_edition_path(guide)
  click_button "Create new edition"
  fill_in "edition_change_note", with: change_note
  click_button "Save"
  publish(force: true)
end

Then /^the change notes should appear in the history for the detailed guide "([^"]*)" in reverse chronological order$/ do |title|
  detailed_guide = DetailedGuide.find_by_title!(title)
  visit detailed_guide_path(detailed_guide.document)
  document_history = detailed_guide.document.change_history
  change_notes = find('.change-notes').all('.note')
  assert_equal document_history.length, change_notes.length
  document_history.zip(change_notes).each do |history, note|
    assert_equal history.note, note.text.strip
  end
end

When(/^I start drafting a new edition for the detailed guide "([^"]*)"$/) do |guide_title|
  guide = DetailedGuide.latest_edition.find_by_title!(guide_title)
  visit admin_edition_path(guide)
  click_button "Create new edition"
  fill_in "edition_change_note", with: "Example change note"
end

Then(/^there should be (\d+) detailed guide editions?$/) do |guide_count|
  assert_equal guide_count.to_i, DetailedGuide.count
end
