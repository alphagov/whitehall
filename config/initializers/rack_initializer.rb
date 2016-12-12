# This initializer is only necessary for the admin configuration of Whitehall.
# Rack::Utils.key_space_limit is the maximum number of form parameters to parse.
if ENV.has_key?("KEY_SPACE_LIMIT")
  # http://stackoverflow.com/a/9123664/61435
  if Rack::Utils.respond_to?("key_space_limit=")
    Rack::Utils.key_space_limit = Integer(ENV["KEY_SPACE_LIMIT"])
  end
end
