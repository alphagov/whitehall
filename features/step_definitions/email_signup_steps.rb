require 'uri'

Then(/^govuk_delivery should be sent the feed subscription URL$/) do
  if subscription_link = find('.feeds .govdelivery')
    subscription_href = subscription_link['href']
  else
    fail "Cannot find the govdelivery email link"
  end

  parsed_url = URI.parse(subscription_href)
  parsed_params = CGI.parse(parsed_url.query)
  feed_url = Rack::Utils.unescape(parsed_params['feed'].first)

  mock_client = mock_govdelivery_client

  mock_client.expects(:signup_url).with(feed_url).returns(current_url)
end


When(/^I sign up for emails$/) do
  within '.feeds' do
    click_on 'email'
  end

  click_on 'Create subscription'
end

Then(/^a notification should be sent for subscribers to the role "(.*?)" and for subscribers to the person "(.*?)"$/) do |role_name, person_name|
  mock_client = mock_govdelivery_client

  role = Role.find_by_name(role_name)
  person = find_person(person_name)

  role_page_atom = polymorphic_url(role, format: "atom")
  person_page_atom = polymorphic_url(person, format: "atom")

  mock_client.expects(:notify).with(
    all_of(includes(role_page_atom), includes(person_page_atom)),
    anything,
    anything
  )
end

Then(/^a notification should be not sent for subscribers to the role "(.*?)" or for subscribers to the person "(.*?)"$/) do |role_name, person_name|
  mock_client = mock_govdelivery_client

  role = Role.find_by_name(role_name)
  person = find_person(person_name)

  role_page_atom = polymorphic_url(role, format: "atom")
  person_page_atom = polymorphic_url(person, format: "atom")

  mock_client.expects(:notify).with(
    all_of(includes(role_page_atom), includes(person_page_atom)),
    anything,
    anything
  ).never
end

def mock_govdelivery_client
  mock_client = mock
  mock_client.stub_everything
  Whitehall.stubs(govuk_delivery_client: mock_client)

  return mock_client
end
