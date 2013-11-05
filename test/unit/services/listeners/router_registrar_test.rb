require 'test_helper'
require 'gds_api/router'

class ServiceListeners::RouterRegistrarTest < ActiveSupport::TestCase

  test "registers a DetailedGuide with the router" do
    edition = create(:published_detailed_guide)
    RouterAddRouteWorker.expects(:perform_async).with("/#{edition.slug}").once
    ServiceListeners::RouterRegistrar.new(edition).register!
  end

  test "does not register other document types" do
    edition = build(:published_publication)
    RouterAddRouteWorker.expects(:perform_async).never
    ServiceListeners::RouterRegistrar.new(edition).register!
  end

  test "removes DetailedGuides from the router" do
    edition = create(:published_detailed_guide)
    RouterDeleteRouteWorker.expects(:perform_async).with("/#{edition.slug}").once
    ServiceListeners::RouterRegistrar.new(edition).unregister!
  end

  test "does not remove other document types" do
    edition = build(:published_publication)
    RouterDeleteRouteWorker.expects(:perform_async).never
    ServiceListeners::RouterRegistrar.new(edition).unregister!
  end

end
