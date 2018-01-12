module Whitehall
  class NewRelicDeveloperMode
    def initialize(app, _options = {})
      @app = app
    end

    def call(env)
      status, headers, response = @app.call(env)
      if %r{^/newrelic}.match? env['PATH_INFO']
        headers["X-Slimmer-Skip"] = "true"
      end
      [status, headers, response]
    end
  end
end
