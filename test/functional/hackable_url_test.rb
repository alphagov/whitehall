require "test_helper"

class HackableUrlTest < ActiveSupport::TestCase
  test "should always provide an index for resources that have a show action" do
    all_routes = Rails.application.routes.routes

    resource_routes = Rails.application.routes.routes.select do |route|
      show_public_resource_route?(route) && !singleton_resource_route?(route)
    end

    resource_routes.each do |resource_route|
      index_route = all_routes.detect {|r| matching_index_route?(r, resource_route)}
      assert index_route, "#{resource_route.path} should have an index action equivalent"
    end
  end

  def show_public_resource_route?(route)
    route.requirements[:action] == 'show' && !route.path.match(/\/admin\//)
  end

  def singleton_resource_route?(route)
    !route.segment_keys.include?(:id)
  end

  def matching_index_route?(candidate, resource_route)
    candidate.requirements[:action] == 'index' && candidate.requirements[:controller] == resource_route.requirements[:controller]
  end
end