GDS::SSO.config do |config|
  config.user_model   = "User"
  config.oauth_id     = 'abcdefghjasndjkasndwhitehall'
  config.oauth_secret = 'secret'
  config.oauth_root_url = Plek.current.find("signon")
  config.default_scope = "Whitehall"
  config.basic_auth_user = 'api'
  config.basic_auth_password = 'defined_on_rollout_not'
end
