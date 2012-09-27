require 'gds_api/content_api'

Whitehall.mainstream_content_api = GdsApi::ContentApi.new(Plek.current.environment)
