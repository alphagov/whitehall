require 'test_helper'
require 'gds_api/router'

class ServiceListeners::RouterRegistrarTest < ActiveSupport::TestCase

  test "registers a DetailedGuide with the router" do
    edition = create(:published_detailed_guide)
    GdsApi::Router.any_instance.expects(:add_route).with("/#{edition.slug}", "exact", "whitehall-frontend")
    ServiceListeners::RouterRegistrar.new(edition).register!
  end

  test "does not register other document types" do
    edition = create(:published_publication)
    GdsApi::Router.any_instance.expects(:add_route).never
    ServiceListeners::RouterRegistrar.new(edition).register!
  end

  test "removes DetailedGuides from the router" do
    edition = create(:published_detailed_guide)
    GdsApi::Router.any_instance.expects(:delete_route).with("/#{edition.slug}", "exact", "whitehall-frontend")
    ServiceListeners::RouterRegistrar.new(edition).unregister!
  end

  test "does not remove other document types" do
    edition = create(:published_publication)
    GdsApi::Router.any_instance.expects(:delete_route).never
    ServiceListeners::RouterRegistrar.new(edition).unregister!
  end
end
