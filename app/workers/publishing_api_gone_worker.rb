class PublishingApiGoneWorker < PublishingApiWorker
  def perform(content_id, alternative_path, explanation, locale, allow_draft = false)
    if explanation.present?
      rendered_explanation = Whitehall::GovspeakRenderer
        .new.govspeak_to_html(explanation)
    end

    Whitehall.publishing_api_v2_client.unpublish(
      content_id,
      alternative_path: alternative_path,
      explanation: rendered_explanation,
      type: "gone",
      locale: locale,
      allow_draft: allow_draft,
      discard_drafts: !allow_draft
    )
  end
end
