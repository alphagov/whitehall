GDS::SSO.config do |config|
  config.user_model   = "User"
  config.oauth_id     = 'abcdefghjasndjkasndwhitehall'
  config.oauth_secret = 'secret'
  config.oauth_root_url = Plek.find("signon")
end
