require 'gds_api/content_api'

class GdsApi::ContentApi::Fake
  def tag(tag)
    {}
  end

  def tags(tag_type, options = {})
    []
  end

  def artefact(*args)
    nil
  end
end

if Rails.env.test?
  Whitehall.content_api = GdsApi::ContentApi::Fake.new
else
  Whitehall.content_api = GdsApi::ContentApi.new(Plek.find("contentapi"))
end
