require 'test_helper'
require 'gds_api/router'

class RouterDeleteRouteWorkerTest < ActiveSupport::TestCase
  test "deletes route from router" do
    GdsApi::Router.any_instance.expects(:delete_route).with("/slug-here", "exact", "whitehall-frontend").once
    RouterDeleteRouteWorker.new.perform("/slug-here")
  end

  test "handles case where route doesn't yet exist" do
    GdsApi::Router.any_instance.stubs(:delete_route).raises(GdsApi::HTTPNotFound, 404)
    assert_nothing_raised do
      RouterDeleteRouteWorker.new.perform("/slug-here")
    end
  end
end
