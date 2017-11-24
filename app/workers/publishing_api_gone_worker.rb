class PublishingApiGoneWorker < PublishingApiWorker
  def perform(content_id, alternative_path, explanation, locale, allow_draft = false)
    if explanation.present?
      rendered_explanation = Whitehall::GovspeakRenderer
        .new.govspeak_to_html(explanation)
    end

    alternative_path_with_no_trailing_space = alternative_path.rstrip if alternative_path

    Services.publishing_api.unpublish(
      content_id,
      alternative_path: alternative_path_with_no_trailing_space,
      explanation: rendered_explanation,
      type: "gone",
      locale: locale,
      allow_draft: allow_draft,
      discard_drafts: !allow_draft
    )
  rescue GdsApi::HTTPNotFound
    # nothing to do here as we can't unpublish something that doesn't exist
    nil
  rescue GdsApi::HTTPUnprocessableEntity => e
    # retrying is unlikely to fix the problem, we can send the error straight to Sentry
    GovukError.notify(e)
  end
end
