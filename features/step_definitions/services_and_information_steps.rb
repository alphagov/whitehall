When(/^I click the link to the full list of topics for that organisation$/) do
  stub_rummager_response
  click_link 'Full list of topics'
end

Then(/^I can see a link to a "(.*?)" for the "(.*?)" organisation$/) do |link_title, org_name|
  organisation = Organisation.find_by_name(org_name)

  assert page.has_link?(link_title, href: services_and_information_path(organisation))
end

Then(/^I should see a list of documents related to the Cabinet Office org grouped by sector title$/) do
  titles_returned_by_stubbed_response = ["Waste", "Environmental permits"]

  titles_returned_by_stubbed_response.each do |title|
    assert page.has_content?(title), "Sector title not present on page"
  end
end
