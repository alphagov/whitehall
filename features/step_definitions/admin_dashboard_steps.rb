When(/^I visit the admin dashboard$/) do
  visit admin_root_path
end

Then(/^I should see the draft document "([^"]*)"$/) do |title|
  if using_design_system?
    expect(all(".govuk-table")[0].all(".govuk-table__cell")[1].text).to eq title
  else
    edition = Edition.find_by!(title:).document.latest_edition
    expect(page).to have_selector(".draft-documents #{record_css_selector(edition)}")
  end
end

Then(/^I should see the force published document "([^"]*)"$/) do |title|
  if using_design_system?
    expect(all(".govuk-table")[1].all(".govuk-table__cell")[1].text).to eq title
  else
    edition = Edition.find_by!(title:).document.latest_edition
    expect(page).to have_selector(".force-published-documents #{record_css_selector(edition)}")
  end
end

Then(/^I should see a link to the content data app$/) do
  ## We track all external link clicks in the design_system layout
  ## so we don't need to check it for when suing the design system.

  if using_design_system?
    expect(find_link("Content Data", href: "https://content-data.test.gov.uk/content")).not_to be_nil
  else
    link = find_link("Content Data", href: "https://content-data.test.gov.uk/content")

    expect("external-link-clicked").to eq(link["data-track-category"])
    expect("https://content-data.test.gov.uk/content").to eq(link["data-track-action"])
    expect("Content Data").to eq(link["data-track-label"])
  end
end
