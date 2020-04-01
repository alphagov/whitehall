class AuthorNotifierWorker < WorkerBase
  def perform(edition_id, *excluded_author_ids)
    AuthorNotifierService.new(
      Edition.find(edition_id),
      *excluded_author_ids.map { |id| User.find(id) },
    )
  end
end
