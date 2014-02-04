require 'uri'

Then(/^a govuk_delivery signup should be sent for the feed subscription URL$/) do
  feed_url = get_govdelivery_url
  mock_client = mock_govdelivery_client
  mock_client.expects(:signup_url).with(feed_url).returns(current_url).once
end

Then(/^a govuk_delivery signup should be sent for the local government feed subscription URL$/) do
  feed_url = get_govdelivery_url_with_relevant_to_local_government
  mock_client = mock_govdelivery_client
  mock_client.expects(:signup_url).with(feed_url).returns(current_url).once
end

Then(/^a govuk_delivery notification should be sent for the feed subscription URL$/) do
  feed_url = get_govdelivery_url
  mock_client = mock_govdelivery_client
  mock_client.expects(:notify).with(includes(feed_url), anything, anything).once
end

Then(/^a govuk_delivery notification should be sent for the local government feed subscription URL$/) do
  feed_url = get_govdelivery_url_with_relevant_to_local_government
  mock_client = mock_govdelivery_client
  mock_client.expects(:notify).with(includes(feed_url), anything, anything).once
end

Then(/^a govuk_delivery notification should be sent for anything other than the feed subscription URL$/) do
  feed_url = get_govdelivery_url
  mock_client = mock_govdelivery_client
  mock_client.expects(:notify).with(Not(includes(feed_url)), anything, anything).once
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

When(/^I send the latest email in the email curation queue$/) do
  visit admin_email_curation_queue_items_path
  within('.email_curation_queue_item:first-child') do
    click_on 'Send'
  end
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
  ).once
end

Then(/^a notification should be not sent for subscribers to the role "(.*?)" or for subscribers to the person "(.*?)"$/) do |role_name, person_name|
  mock_client = mock_govdelivery_client

  role = Role.find_by_name(role_name)
  person = find_person(person_name)

  role_page_atom = polymorphic_url(role, format: "atom")
  person_page_atom = polymorphic_url(person, format: "atom")

  mock_client.stubs(:notify)
  mock_client.expects(:notify).with(
    all_of(includes(role_page_atom), includes(person_page_atom)),
    anything,
    anything
  ).never
end

def mock_govdelivery_client
  @mock_govdelivery_client ||= begin
    mock_client = mock
    mock_client.stubs(:topic)
    Whitehall.stubs(govuk_delivery_client: mock_client)

    mock_client
  end
end

def get_govdelivery_url
  if subscription_link = find('.feeds .govdelivery')
    subscription_href = subscription_link['href']
  else
    fail "Cannot find the govdelivery email link"
  end

  parsed_url = URI.parse(subscription_href)
  parsed_params = CGI.parse(parsed_url.query)
  return Rack::Utils.unescape(parsed_params['feed'].first)
end

def get_govdelivery_url_with_relevant_to_local_government
  feed_url = get_govdelivery_url
  feed_url + (feed_url.include?("?") ? "&" : "?") + "relevant_to_local_government=1"
end
