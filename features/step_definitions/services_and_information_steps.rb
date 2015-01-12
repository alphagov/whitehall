When(/^I view the services and information page for the "(.*?)" organisation$/) do |org_name|
  org = Organisation.find_by(name: org_name)
  stub_rummager_response
  visit services_and_information_path(org)
end

When(/^I view the services and information page for the "(.*?)" without featured services and guidance$/) do |org_name|
  org = Organisation.find_by(name: org_name)
  stub_empty_rummager_response
  visit services_and_information_path(org)
end

Then(/^I should see a list of sub\-sectors in which some documents are related to the Cabinet Office organisation, with a list of documents in each sub\-sector$/) do
  titles_returned_by_stubbed_response = ["Waste", "Environmental permits"]

  titles_returned_by_stubbed_response.each do |title|
    assert page.has_content?(title), "Sector title not present on page"
  end
end
