When(/^I view the "Navigation" tab of the document titled "([^"]*)"$/) do |title|
  @edition = StandardEdition.find_by!(title:)
  step 'I view the "Navigation" tab'
end

When(/^I add a new child page titled "([^"]*)" to the edition$/) do |title|
  visit child_pages_admin_standard_edition_path(@edition)
  click_link "Add new child page"
  step "I fill in and submit the form with title '#{title}'"
  expect(page).to have_css(".govuk-notification-banner__heading", text: "Your document has been saved")
end

Given(/^the edition has child pages titled (.+)$/) do |titles|
  titles.scan(/"([^"]*)"/).flatten.each do |title|
    child_edition = create(:draft_standard_edition, title:)
    ParentChildRelationship.create!(parent_edition: @edition, child_document: child_edition.document)
  end
end

When(/^I add (.+) to the navigation of the edition$/) do |titles|
  visit navigation_admin_standard_edition_path(@edition)
  click_link "Add navigation menu"
  titles.scan(/"([^"]*)"/).flatten.each do |title|
    check title
  end
  click_button "Add navigation menu"
end

Then(/^I should (not )?see the "Add navigation menu" button$/) do |negate|
  if negate
    expect(page).not_to have_link("Add navigation menu")
  else
    expect(page).to have_link("Add navigation menu")
  end
end

Then(/^I should see (.+) in the navigation table$/) do |titles|
  titles.scan(/"([^"]*)"/).flatten.each do |title|
    expect(page).to have_css("table td", text: title)
  end
end

Then(/^I should not see (.+) in the navigation table$/) do |titles|
  titles.scan(/"([^"]*)"/).flatten.each do |title|
    expect(page).not_to have_css("table td", text: title)
  end
end

Then(/^I should see (.+) as options in the navigation form$/) do |titles|
  visit navigation_admin_standard_edition_path(@edition)
  click_link "Add navigation menu"
  titles.scan(/"([^"]*)"/).flatten.each do |title|
    expect(page).to have_unchecked_field(title)
  end
end
