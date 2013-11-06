require 'gds_api/router'
# We never have to go to the Router during Feature tests. Disable.
module GdsApi
  class Router
    def add_route(path, type, backend_id, options={})
      true
    end

    def delete_route(path, type, backend_id, options={})
      true
    end
  end
end
