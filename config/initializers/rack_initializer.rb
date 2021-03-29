# This initializer is only necessary for the admin configuration of Whitehall.
# Rack::Utils.key_space_limit is the maximum number of form parameters to parse.
# http://stackoverflow.com/a/9123664/61435
if ENV.key?("KEY_SPACE_LIMIT") && Rack::Utils.respond_to?("key_space_limit=")
  Rack::Utils.key_space_limit = Integer(ENV["KEY_SPACE_LIMIT"])
end
