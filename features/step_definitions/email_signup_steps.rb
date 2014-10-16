require 'uri'

Given(/^govuk delivery exists$/) do
  mock_govuk_delivery_client
end

When(/^I sign up for emails$/) do
  within '.feeds' do
    click_on 'email'
  end

  click_on 'Create subscription'
end

When(/^I sign up for emails, checking the relevant to local government box$/) do
  within '.feeds' do
    click_on 'email'
  end

  check 'Only include results relevant to local government'
  click_on 'Create subscription'
end

Then(/^I should be signed up for the all publications mailing list$/) do
  assert_signed_up_to_mailing_list("/government/publications.atom", "publications")
end

Then(/^I should be signed up to the correspondence publications mailing list$/) do
  assert_signed_up_to_mailing_list("/government/publications.atom?publication_filter_option=correspondence", "correspondence")
end

Then(/^I should be signed up for the all announcements mailing list$/) do
  assert_signed_up_to_mailing_list("/government/announcements.atom", "announcements")
end

Then(/^I should be signed up for the news stories mailing list$/) do
  assert_signed_up_to_mailing_list("/government/announcements.atom?announcement_filter_option=news-stories", "news stories")
end

Then(/^I should be signed up for the local government news stories mailing list$/) do
  assert_signed_up_to_mailing_list("/government/announcements.atom?announcement_filter_option=news-stories&relevant_to_local_government=1", "news stories which are relevant to local government")
end

Then(/^I should be signed up for the "(.*?)" organisation mailing list$/) do |org_name|
  org_slug = Organisation.find_by_name!(org_name).slug
  assert_signed_up_to_mailing_list("/government/organisations/#{org_slug}.atom", org_name)
end

Then(/^I should be signed up for the "(.*?)" role mailing list$/) do |role_name|
  role_slug = Role.find_by_name!(role_name).slug
  assert_signed_up_to_mailing_list("/government/ministers/#{role_slug}.atom", role_name)
end

Then(/^I should be signed up for the "(.*?)" person mailing list$/) do |person_name|
  names = person_name.split
  person_slug = Person.find_by_forename_and_surname!(names[0], names[1]).slug
  assert_signed_up_to_mailing_list("/government/people/#{person_slug}.atom", person_name)
end

Then(/^I should be signed up for the "(.*?)" policy mailing list$/) do |policy_name|
  policy_slug = Policy.find_by_title!(policy_name).slug
  assert_signed_up_to_mailing_list("/government/policies/#{policy_slug}/activity.atom", policy_name)
end

Then(/^I should be signed up for the "(.*?)" topical event mailing list$/) do |topical_event_name|
  topical_event_slug = TopicalEvent.find_by_name!(topical_event_name).slug
  assert_signed_up_to_mailing_list("/government/topical-events/#{topical_event_slug}.atom", topical_event_name)
end

Then(/^I should be signed up for the "(.*?)" topic mailing list$/) do |topic_name|
  topic_slug = Topic.find_by_name!(topic_name).slug
  assert_signed_up_to_mailing_list("/government/topics/#{topic_slug}.atom", topic_name)
end

Then(/^I should be signed up for the "(.*?)" world location mailing list$/) do |world_location_name|
  world_location_slug = WorldLocation.find_by_name!(world_location_name).slug
  assert_signed_up_to_mailing_list("/government/world/#{world_location_slug}.atom", world_location_name)
end

Then(/^a govuk_delivery notification should have been sent to the mailing list I signed up for$/) do
  mock_govuk_delivery_client.assert_method_called(:notify, with: ->(feed_urls, _subject, _body) {
    feed_urls.include?(@feed_signed_up_to)
  })
end

Then(/^no govuk_delivery notifications should have been sent yet$/) do
  mock_govuk_delivery_client.refute_method_called(:notify)
end

When(/^I visit the "(.*?)" organisation email signup information page$/) do |org_name|
  visit_organisation_email_signup_information_page(org_name)
end

Then(/^I should see email signup information for "(.*?)"$/) do |organisation_name|
  assert(page.has_link?("Safety alerts", href: "/drug-device-alerts/email-signup"))
  assert(page.has_link?("Drug safety updates", href: "/drug-safety-update/email-signup"))
  assert(page.has_link?("News and publications from the MHRA",
    href: "/government/email-signup/new?email_signup%5Bfeed%5D=https%3A%2F%2Fwww.gov.uk%2Fgovernment%2Forganisations%2Fmedicines-and-healthcare-products-regulatory-agency.atom")
  )
end

def mock_govuk_delivery_client
  @mock_client ||= RetrospectiveStub.new.tap { |mock_client|
    mock_client.stub :topic
    mock_client.stub :signup_url, returns: public_url("/email_signup_url")
    mock_client.stub :notify
    Whitehall.stubs(govuk_delivery_client: mock_client)
  }
end

def assert_signed_up_to_mailing_list(feed_path, description)
  @feed_signed_up_to = public_url(feed_path)
  mock_govuk_delivery_client.assert_method_called(:topic, with: [@feed_signed_up_to, description])
  mock_govuk_delivery_client.assert_method_called(:signup_url, with: [@feed_signed_up_to])
end
