require 'gds_api/content_api'

class GdsApi::ContentApi::Fake
  def tag(_tag)
    {}
  end

  def tags(_tag_type)
    []
  end

  def artefact(*_args)
    nil
  end
end

if endpoint_url = ENV["CONTENT_API_ENDPOINT_URL"]
  credentials = { user: ENV["CONTENT_API_USERNAME"], password: ENV["CONTENT_API_PASSWORD"] }
  Whitehall.content_api = GdsApi::ContentApi.new(endpoint_url, basic_auth: credentials)
elsif Rails.env.production?
  Whitehall.content_api = GdsApi::ContentApi.new(Plek.current.find("contentapi"))
else
  Whitehall.content_api = GdsApi::ContentApi::Fake.new
end
