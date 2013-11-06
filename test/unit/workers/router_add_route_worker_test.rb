require 'test_helper'
require 'gds_api/router'

class RouterAddRouteWorkerTest < ActiveSupport::TestCase
  test "adds route to router" do
    GdsApi::Router.any_instance.expects(:add_route).with("/slug-here", "exact", "whitehall-frontend").once
    RouterAddRouteWorker.new.perform("/slug-here")
  end
end
