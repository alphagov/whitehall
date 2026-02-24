class PublishingApiRedirectJob < PublishingApiJob
  # Retrying is unlikely to fix the problem - so disable retries.
  sidekiq_options retry: 0

  def perform(content_id, destination, locale, allow_draft = false)
    Services.publishing_api.unpublish(
      content_id,
      type: "redirect",
      locale:,
      alternative_path: destination.strip,
      allow_draft:,
      discard_drafts: !allow_draft,
    )
  rescue GdsApi::HTTPNotFound
    # nothing to do here as we can't unpublish something that doesn't exist
    nil
  end
end
