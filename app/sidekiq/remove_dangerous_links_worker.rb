class RemoveDangerousLinksWorker < WorkerBase
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
    edition = find_and_validate_edition(edition_id)

    dangerous_links = edition.link_check_report.danger_links.map(&:uri)
    return unless dangerous_links.any?

    sanitized_body = remove_danger_links(edition, dangerous_links)
    create_sanitized_edition_and_publish_it!(edition, dangerous_links, sanitized_body) unless sanitized_body == edition.body
  end

private

  def find_and_validate_edition(edition_id)
    edition = Edition.find(edition_id)
    if !edition.published?
      raise ArgumentError, "#{edition.state} edition with ID #{edition_id} passed to RemoveDangerousLinksWorker: expecting 'published'"
    elsif edition.document.latest_edition.draft?
      raise ArgumentError, "Published edition with ID #{edition_id} passed to RemoveDangerousLinksWorker but it already has a draft. Aborting to avoid overwriting."
    end

    edition
  end

  def create_sanitized_edition_and_publish_it!(edition, dangerous_links, sanitized_body)
    AuditTrail.acting_as(robot_user) do
      # Set up the new draft edition and remove the dangerous links
      draft_edition = edition.create_draft(robot_user)
      draft_edition.update!(minor_change: true, body: sanitized_body)

      #  Publish the new edition
      edition_publisher = Whitehall.edition_services.force_publisher(
        draft_edition,
        user: robot_user,
        remark: "Dangerous links automatically removed: #{dangerous_links.join(', ')}",
      )
      edition_publisher.perform!
    end
  end

  def robot_user
    User.find_by(name: "Scheduled Publishing Robot", uid: nil)
  end

  def remove_danger_links(edition, dangerous_links)
    sanitized_body = edition.body.dup
    dangerous_links.each do |uri|
      sanitized_body.gsub!(uri, "#link-removed")
    end
    sanitized_body
  end
end
