class ActionController::Base
  before_filter proc {
    response.headers[Slimmer::SKIP_HEADER] = "true" unless ENV["USE_SLIMMER"]
  }
end
