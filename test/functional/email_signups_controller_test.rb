require 'test_helper'

class EmailSignupsControllerTest < ActionController::TestCase
  include FeedHelper

  view_test 'GET :new with a valid field displays the subscription form' do
    topic = create(:topic)
    get :new, email_signup: { feed: atom_feed_url_for(topic) }

    assert_response :success
    assert_select "input[name='email_signup[feed]'][value='#{atom_feed_url_for(topic)}']"
  end

  view_test 'GET :new with an invalid feed shows an error message' do
    get :new, email_signup: { feed: 'http://nonse-feed.atom' }

    assert_response :success
    refute_select "input[name='email_signup[feed]']"
    assert_select "p", text: /we could not find a valid email alerts feed/
  end

  test 'POST :create with a valid email signup redirects to the govdelivery URL' do
    Whitehall.govuk_delivery_client.stubs(:signup_url).returns('http://govdelivery_signup_url')
    topic = create(:topic)
    post :create, email_signup: { feed: atom_feed_url_for(topic) }

    assert_response :redirect
    assert_redirected_to 'http://govdelivery_signup_url'
  end

  view_test 'POST :create with an invalid email signup shows an error message' do
    Whitehall.govuk_delivery_client.expects(:topic).never
    post :create, email_signup: { feed: 'http://gov.uk/invalid/feed.atom'}

    assert_response :success
    assert_select "p", text: /we could not find a valid email alerts feed/
  end
end
