class RemoveDangerousLinksJob < JobBase
  sidekiq_options queue: "publishing_api"

  # Don't retry this job if it fails, because:
  # 1. It's all 'internal' - so won't fail if a third party API is down,
  #    and any failure is unlikely to resolve itself on a retry.
  # 2. There are currently some cases where `ArgumentError` is raised
  #    'legitimately'. E.g. for 'withdrawn' editions, for which we
  #    haven't yet written the code to auto-remove dangerous links.
  #    NB, they're logged as errors (rather than logs in Kibana) because
  #    they're still 'actionable' errors that should be resolved on a
  #    case by case basis.
  sidekiq_options retry: 0

  def perform(edition_id)
    edition = Edition.find(edition_id)
    dangerous_links = edition.link_check_report.danger_links.map(&:uri)
    return unless dangerous_links.any?

    FindAndReplaceJob.new.perform(
      "edition_id" => edition_id,
      "replacements" => dangerous_links.map { |uri| { "find" => uri, "replace" => "#link-removed" } },
      "changenote" => "Dangerous links automatically removed: #{dangerous_links.join(', ')}",
    )
  end
end
