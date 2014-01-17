require 'test_helper'

class EmailSignupsControllerTest < ActionController::TestCase

  view_test 'GET new will display error messages if the email signup is not valid' do
    get :new
    assert_match /Feed can&#x27;t be blank/, response.body
  end

  test 'POST create will re-render the "new" template if the constructed email signup is not valid' do
    post :create, email_signup: {}
    assert_template 'new'
  end

end
