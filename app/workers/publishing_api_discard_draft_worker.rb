class PublishingApiDiscardDraftWorker < PublishingApiWorker
  def perform(content_id, locale)
    Services.publishing_api.discard_draft(content_id, locale: locale)
  rescue GdsApi::HTTPNotFound, GdsApi::HTTPUnprocessableEntity
    # nothing to do here as the draft has already been deleted
    # this shouldn't really happen but can still occur due to inconsistencies
    # between this app's data and what's in the Content Store/Publishing API
    nil
  end
end
