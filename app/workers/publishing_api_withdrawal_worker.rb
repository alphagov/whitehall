class PublishingApiWithdrawalWorker < PublishingApiWorker
  # `explanation` and `unpublished_at` come from the unpublishing object. Rather than
  # performing a database query here to look up the `unpublishing` linked to the most
  # recent edition, we pass it in directly because the `unpublishing` isn't always
  # saved in the database yet when this worker runs.
  def perform(content_id, explanation, locale, allow_draft = false, unpublished_at = nil)
    check_if_locked_document(content_id: content_id)

    Services.publishing_api.unpublish(
      content_id,
      type: "withdrawal",
      locale: locale,
      explanation: Whitehall::GovspeakRenderer.new.govspeak_to_html(explanation),
      allow_draft: allow_draft,
      unpublished_at: find_unpublished_at(content_id, unpublished_at),
    )
  rescue GdsApi::HTTPNotFound, GdsApi::HTTPUnprocessableEntity
    # nothing to do here as we can't unpublish something that doesn't exist
    nil
  end

private

  def find_unpublished_at(content_id, given_unpublished_at)
    if given_unpublished_at
      # We call this job both directly and via Sidekiq. When called by Sidekiq, the date gets turned
      # into a string (because jobs must be JSON serialisable) and `Services.publishing_api.unpublish`
      # rejects it.
      Time.zone.parse(given_unpublished_at.to_s)
    else
      # Temporary code to handle old workers that are still in the queue without an `unpublished_at`
      Edition
        .joins(:document)
        .where(documents: { content_id: content_id })
        .where(state: "withdrawn")
        .pick(:updated_at)
    end
  end
end
