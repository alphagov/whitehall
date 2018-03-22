require 'gds_api/exceptions'

class GdsApi::BaseError
  remove_method :raven_context
end
