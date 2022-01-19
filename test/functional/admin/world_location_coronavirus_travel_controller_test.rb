require "test_helper"

class Admin::WorldLocationCoronavirusTravelControllerTest < ActionController::TestCase
  should_be_an_admin_controller
  should_require_coronavirus_travel_permission_to_access :world_location, :edit
end
