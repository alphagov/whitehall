require 'gds_api/content_api'

class GdsApi::ContentApi::Fake
  def tag(tag)
    {}
  end
end

if endpoint_url = ENV["CONTENT_API_ENDPOINT_URL"]
  credentials = { user: ENV["CONTENT_API_USERNAME"], password: ENV["CONTENT_API_PASSWORD"] }
  Whitehall.mainstream_content_api = GdsApi::ContentApi.new(nil, endpoint_url: endpoint_url, basic_auth: credentials)
elsif Rails.env.production?
  Whitehall.mainstream_content_api = GdsApi::ContentApi.new(Plek.current.environment)
else
  Whitehall.mainstream_content_api = GdsApi::ContentApi::Fake.new
end
