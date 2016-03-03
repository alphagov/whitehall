Before('@real_content_api') do
  Whitehall.content_api = GdsApi::ContentApi.new(Plek.find('contentapi'))
  Whitehall.content_store = GdsApi::ContentStore.new(Plek.find('content-store'))
end

After('@real_content_api') do
  Whitehall.content_api = GdsApi::ContentApi::Fake.new
  Whitehall.content_store = GdsApi::ContentStore::Fake.new
end
