When /^I write some copy to describe the featured topics and policies for the executive office "([^"]*)"$/ do |org_name|
  @the_featuring_org = Organisation.where(name: org_name).first
  @the_featuring_org_ftap_copy = "The #{@the_featuring_org.name} is totes involved in all of these things. Do ch-ch-check 'em out! LOL"
  visit admin_organisation_path(@the_featuring_org)
  click_on 'Featured topics and policies'
  fill_in 'Summary', with: @the_featuring_org_ftap_copy
  click_on 'Save'
end

When /^I feature some topics and policies for the executive office in a specific order$/ do
  pending
end

Then /^I see my copy on the executive office page$/ do
  visit_organisation @the_featuring_org.name

  within '#featured-topics-and-policies' do
    assert page.has_content?(@the_featuring_org_ftap_copy)
  end
end

Then /^the featured topics and policies are in my specified order$/ do
  pending
end

Then /^I am invited to click through to see all the policies the executive office is involved with$/ do
  pending
end
