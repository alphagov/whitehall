if Object.const_defined?('LogStasher') && LogStasher.enabled
  LogStasher.add_custom_fields do |fields|
    # Mirrors Nginx request logging, e.g GET /path/here HTTP/1.1
    fields[:request] = "#{request.request_method} #{request.fullpath} #{request.headers['SERVER_PROTOCOL']}"
    # Pass the request id to logging
    fields[:govuk_request_id] = request.headers['GOVUK-Request-Id']
    fields[:varnish_id] = request.headers['X-Varnish']
  end
end
