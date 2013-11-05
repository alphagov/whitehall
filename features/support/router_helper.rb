require 'gds_api/router'
# We never have to go to the Router during Feature tests. Disable.
GdsApi::Router.any_instance.stubs(:add_route).returns true
GdsApi::Router.any_instance.stubs(:delete_route).returns true
