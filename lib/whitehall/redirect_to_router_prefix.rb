module Whitehall
  class RedirectToRouterPrefix
    def initialize(app)
      @app = app
    end

    def call(env)
      if path_is_under_prefix(env) || path_is_for_javascript_tests(env)
        @app.call(env)
      else
        [301, {"Location" => (Whitehall.router_prefix + env["PATH_INFO"])}, []]
      end
    end

    private

    def path_is_under_prefix(env)
      env["PATH_INFO"].index(Whitehall.router_prefix) == 0
    end

    def path_is_for_javascript_tests(env)
      env["PATH_INFO"].index("/test") == 0
    end
  end
end