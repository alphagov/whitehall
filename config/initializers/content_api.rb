require 'gds_api/content_api'

class GdsApi::ContentApi::Fake
  def tag(tag, tag_type)
    {}
  end

  def tags(tag_type, options = {})
    []
  end

  def artefact(*args)
    nil
  end

  def artefacts_tagged_to_mainstream_browse_pages
    []
  end
end

class GdsApi::ContentApi
  def artefacts_tagged_to_mainstream_browse_pages
    get_json!("#{base_url}/whitehall-artefacts-tagged-to-mainstream-browse-pages.json")
  end
end

if Rails.env.test?
  Whitehall.content_api = GdsApi::ContentApi::Fake.new
else
  Whitehall.content_api = GdsApi::ContentApi.new(Plek.find("contentapi"))
end
