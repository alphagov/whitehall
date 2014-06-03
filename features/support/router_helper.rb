require 'gds_api/router'
# We never have to go to the Router during Feature tests. Disable.
module GdsApi
  class Router
    def add_route(_path, _type, _backend_id, _options = {})
      true
    end

    def delete_route(_path, _type, _backend_id, _options = {})
      true
    end
  end
end
