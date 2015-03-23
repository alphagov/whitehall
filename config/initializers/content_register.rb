require 'gds_api/content_register'

Whitehall.content_register = GdsApi::ContentRegister.new(
  Plek.find('content-register')
)
