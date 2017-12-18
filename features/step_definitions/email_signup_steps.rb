Given(/^email alert api exists$/) do
  Services.stubs(:email_alert_api).returns(mock_email_alert_api)
end

When(/^I sign up for emails$/) do
  within '.feeds' do
    click_on 'email'
  end

  # There is a bug which is causes external urls to get requested from the
  # server. So catch the routing error and handle it so we can continue to
  # assert that the right things have happened to generate the redirect.
  begin
    click_on 'Create subscription'
  rescue ActionController::RoutingError
  end
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

Then(/^I should be signed up for the "(.*?)" organisation mailing list$/) do |org_name|
  org_slug = Organisation.find_by!(name: org_name).slug
  assert_signed_up_to_mailing_list("/government/organisations/#{org_slug}.atom", org_name)
end

Then(/^I should be signed up for the "(.*?)" role mailing list$/) do |role_name|
  role_slug = Role.find_by!(name: role_name).slug
  assert_signed_up_to_mailing_list("/government/ministers/#{role_slug}.atom", role_name)
end

Then(/^I should be signed up for the "(.*?)" person mailing list$/) do |person_name|
  names = person_name.split
  person_slug = Person.find_by!(forename: names[0], surname: names[1]).slug
  assert_signed_up_to_mailing_list("/government/people/#{person_slug}.atom", person_name)
end

Then(/^I should be signed up for the "(.*?)" topical event mailing list$/) do |topical_event_name|
  topical_event_slug = TopicalEvent.find_by!(name: topical_event_name).slug
  assert_signed_up_to_mailing_list("/government/topical-events/#{topical_event_slug}.atom", topical_event_name)
end

Then(/^I should be signed up for the "(.*?)" topic mailing list$/) do |topic_name|
  topic_slug = Topic.find_by!(name: topic_name).slug
  assert_signed_up_to_mailing_list("/government/topics/#{topic_slug}.atom", topic_name)
end

Then(/^I should be signed up for the "(.*?)" international delegation mailing list$/) do |world_location_name|
  world_location_slug = WorldLocation.find_by!(name: world_location_name).slug
  assert_signed_up_to_mailing_list("/world/#{world_location_slug}.atom", world_location_name)
end

When(/^click the link for the latest email alerts$/) do
  within '.feeds' do
    click_on 'email'
  end
end

Then(/^I should see email signup information for "(.*?)"$/) do |organisation_name|
  assert(page.has_link?("MHRA's alerts and recalls for drugs and medical devices", href: "/drug-device-alerts/email-signup"))
  assert(page.has_link?("Drug Safety Update", href: "/drug-safety-update/email-signup"))
  assert(page.has_link?("MHRA's new publications, statistics, consultations and announcements",
    href: "/government/email-signup/new?email_signup%5Bfeed%5D=https%3A%2F%2Fwww.gov.uk%2Fgovernment%2Forganisations%2Fmedicines-and-healthcare-products-regulatory-agency.atom")
  )
end

def mock_email_alert_api
  @email_mock_client ||= RetrospectiveStub.new.tap do |mock|
    mock.stub(
      :find_or_create_subscriber_list,
      returns: {
        'subscriber_list' => {
          'topic_id' => 'TOPIC_123',
          'subscription_url' => 'http://example.com',
        },
      },
    )
  end
end

def assert_signed_up_to_mailing_list(feed_path, expected_title)
  feed_signed_up_to = public_url(feed_path)
  expected_links = UrlToSubscriberListCriteria.new(feed_signed_up_to).convert

  expected_call = lambda do |args|
    assert_equal expected_links, args.fetch("links")
    assert_equal expected_title, args.fetch("title")
  end
end
