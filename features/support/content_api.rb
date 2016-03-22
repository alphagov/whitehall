Before('@real_content_api') do
  Whitehall.content_api = GdsApi::ContentApi.new(Plek.find('contentapi'))
end

After('@real_content_api') do
  Whitehall.content_api = GdsApi::ContentApi::Fake.new
end
