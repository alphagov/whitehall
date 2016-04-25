require "gds_api/content_store"

Whitehall.content_store = GdsApi::ContentStore.new(Plek.new.find('content-store'))

