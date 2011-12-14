module Whitehall
  class RedirectToRouterPrefix
    def initialize(app)
      @app = app
    end

    def call(env)
      if path_is_under_prefix(env) ||
         path_is_for_javascript_tests(env) ||
         path_is_for_sign_on(env)
        @app.call(env)
      else
        [301, {"Location" => (Whitehall.router_prefix + env["PATH_INFO"])}, []]
      end
    end

    private

    def path_is_under_prefix(env)
      env["PATH_INFO"].starts_with?(Whitehall.router_prefix)
    end

    def path_is_for_javascript_tests(env)
      env["PATH_INFO"].starts_with?("/test")
    end

    def path_is_for_sign_on(env)
      env["PATH_INFO"].starts_with?("/auth")
    end
  end
end