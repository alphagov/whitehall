require "test_helper"

class HackableUrlTest < ActiveSupport::TestCase
  test "should always provide an index for resources that have a show action" do
    all_routes = Rails.application.routes.routes

    resource_routes = all_routes.reject do |route|
      admin_route?(route) || auth_route?(route) || non_public_controller?(route) || api_route?(route) || browse_route?(route) || asset_route?(route)
    end

    resource_routes.each do |resource_route|
      all_possible_hackings_of(resource_route.path).each do |path|
        assert_path_recognized(path, "Path #{path} not recognised by routes - expected because of #{resource_route.path.ast.to_s}")
      end
    end
  end

  def non_public_controller?(route)
    route.requirements[:controller] == "site"
  end

  def admin_route?(route)
    route.path.ast.to_s.match("\/admin")
  end

  def auth_route?(route)
    route.path.ast.to_s.match("\/auth")
  end

  def api_route?(route)
    route.path.ast.to_s.match("\/api")
  end

  def browse_route?(route)
    route.path.ast.to_s.match("\/browse")
  end

  def asset_route?(route)
    route.path.ast.to_s.match("\/government\/uploads")
  end

  def all_possible_hackings_of(path)
    parts = path.ast.to_s.split("/")
    (1...parts.size).map do |num_parts|
      parts[0...num_parts].join("/")
    end.reject {|path| path.empty?}
  end

  def assert_path_recognized(path, message)
    env = Rack::MockRequest.env_for(path, {method: "GET"})
    request = ActionDispatch::Request.new(env)
    called = false
    Rails.application.routes.router.recognize(request) do |r, _, params|
      called = true
    end
    assert called, message
  end
end
