require "test_helper"

class Admin::DocumentCollectionsControllerTest < ActionController::TestCase
  setup do
    login_as :policy_writer
  end

  should_be_an_admin_controller
end
