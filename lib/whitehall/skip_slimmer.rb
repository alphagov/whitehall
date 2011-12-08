module Whitehall
  class SkipSlimmer
    def initialize(app)
      @app = app
    end

    def call(env)
      status, headers, body = @app.call(env)
      headers[Slimmer::SKIP_HEADER] = "true"
      [status, headers, body]
    end
  end
end
