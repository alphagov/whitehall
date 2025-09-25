class PublishingApiGoneWorker < PublishingApiWorker
  include GovspeakHelper
  # Retrying is unlikely to fix the problem - so disable retries.
  sidekiq_options retry: 0

  def perform(content_id, alternative_path, explanation, locale, allow_draft = false)
    if explanation.present?
      rendered_explanation = govspeak_to_html(explanation)
    end

    alternative_path_with_no_trailing_space = alternative_path.rstrip if alternative_path

    Services.publishing_api.unpublish(
      content_id,
      alternative_path: alternative_path_with_no_trailing_space,
      explanation: rendered_explanation,
      type: "gone",
      locale:,
      allow_draft:,
      discard_drafts: !allow_draft,
    )
  rescue GdsApi::HTTPNotFound
    # nothing to do here as we can't unpublish something that doesn't exist
    nil
  end
end
