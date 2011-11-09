require "test_helper"

class HackableUrlTest < ActiveSupport::TestCase
  test "should always provide an index for resources that have a show action" do
    route_requirements = Rails.application.routes.routes.map { |r| r.requirements }
    hash_with_default_empty_array = Hash.new { |h,k| h[k] = [] }
    controller_actions = route_requirements.inject(hash_with_default_empty_array) do |hash,req|
      hash[req[:controller]] << req[:action] unless req[:controller] =~ /^admin\//
      hash
    end
    naughty_controllers = controller_actions.select do |controller,actions|
      actions.include?("show") && !actions.include?("index")
    end.keys
    assert naughty_controllers.empty?, "Controllers which show something should also have an index action, but some don't: #{naughty_controllers.inspect}"
  end
end