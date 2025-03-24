class RemoveDangerousLinksWorker < WorkerBase
  sidekiq_options queue: "publishing_api"

  def perform(edition_id)
    edition = find_and_validate_edition(edition_id)

    dangerous_links = edition.link_check_report.danger_links.map(&:uri)
    return unless dangerous_links.any?

    # Set up the new draft edition and remove the dangerous links
    draft_edition = edition.create_draft(robot_user)
    draft_edition.update!(minor_change: true)
    remove_danger_links!(draft_edition.id, dangerous_links)

    #  Publish the new edition
    edition_publisher = Whitehall.edition_services.force_publisher(
      draft_edition,
      user: robot_user,
      remark: "Dangerous links automatically removed: #{dangerous_links.join(', ')}",
    )
    edition_publisher.perform!
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

  def robot_user
    User.find_by(name: "Scheduled Publishing Robot", uid: nil)
  end

  def remove_danger_links!(edition_id, dangerous_links)
    edition = Edition.find(edition_id)
    sanitized_body = edition.body.dup
    dangerous_links.each do |uri|
      sanitized_body.gsub!(uri, "#link-removed")
    end
    edition.update!(body: sanitized_body)
  end
end
