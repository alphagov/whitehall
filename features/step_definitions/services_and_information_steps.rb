When(/^I click the link to the full list of topics for that organisation$/) do
  click_link "Full list of topics"
end

Then(/^I can see a link to a "(.*?)" for the "(.*?)" organisation$/) do |link_title, org_name|
  organisation = Organisation.find_by_name(org_name)

  assert page.has_link?(link_title, href: services_and_information_path(organisation))
end

Then(/^I should see a list of documents related to the Cabinet Office org grouped by sector$/) do
  specialist_subsectors_returned_by_fixture  = ["Asylum policy", "Licensing"]

  specialist_subsectors_returned_by_fixture.each do |subsector|
    assert page.has_content?(subsector), "Sector information not present on page"
  end
end
