class PresentPageToPublishingApi
  def publish(presenter_class)
    payload = presenter_class.new
    Services.publishing_api.put_content(payload.content_id, payload.content)
    Services.publishing_api.patch_links(payload.content_id, links: payload.links)
    Services.publishing_api.publish(payload.content_id, nil, locale: payload.content[:locale])
  end
end
