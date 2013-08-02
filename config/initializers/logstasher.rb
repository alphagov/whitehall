if Object.const_defined?('LogStasher') && LogStasher.enabled
  LogStasher.add_custom_fields do |fields|
    fields[:request] = "#{request.request_method} #{request.path} #{request.headers['SERVER_PROTOCOL']}"
  end
end
