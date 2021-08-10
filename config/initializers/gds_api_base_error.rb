require "gds_api/exceptions"

class GdsApi::BaseError
  remove_method :sentry_context
end
