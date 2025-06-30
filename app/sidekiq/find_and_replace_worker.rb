class FindAndReplaceWorker < WorkerBase
  # Don't retry this job if it fails, because it's typically all
  # ‘internal’ – so it won’t fail because a third-party API is down,
  # and any failure is unlikely to resolve itself on a retry.
  sidekiq_options queue: "publishing_api", retry: 0

  def perform(args)
    edition_id = args["edition_id"]
    replacements = args["replacements"]
    validate_params!(edition_id, replacements)
    edition = find_and_validate_edition(edition_id)
    return unless edition

    updated_body = find_and_replace(edition.body, replacements)
    if updated_body == edition.body
      log(
        "Skipping: Edition #{edition.id}. Its body doesn't need changing.",
      )
      return
    end

    edition.editable? ? update_draft(edition, updated_body) : create_and_publish_draft(edition, updated_body)
  end

private

  def validate_params!(edition_id, replacements)
    missing = []
    missing << "edition_id" if edition_id.blank?
    missing << "replacements" if replacements.blank?
    raise ArgumentError, "Error: missing keyword argument(s): #{missing.join(', ')}" if missing.any?

    unless valid_replacements_payload?(replacements)
      raise ArgumentError, "Error: invalid 'replacements' argument (must be an array of string-keyed hashes with non-blank 'find' and 'replace')"
    end
  end

  def valid_replacements_payload?(replacements)
    replacements.is_a?(Array) &&
      replacements.all? do |h|
        h.is_a?(Hash) &&
          h.key?("find") && h["find"].present? &&
          h.key?("replace") && h["replace"].present?
      end
  end

  def find_and_validate_edition(edition_id)
    edition = Edition.find(edition_id)
    latest = edition.document.latest_edition
    if edition != latest
      log(
        "Aborting: Edition #{edition_id} was passed, but there is a more recent Edition (#{latest.id}).",
      )
      return false
    elsif %w[unpublished withdrawn].include?(edition.state)
      log(
        "Aborting: Edition #{edition_id} was passed, but is in state '#{edition.state}' and cannot be acted on.",
      )
      return false
    end

    edition
  end

  def log(message)
    Rails.logger.info(message)
  end

  def find_and_replace(body, replacements)
    updated_body = body.dup
    replacements.each do |replacement|
      updated_body.gsub!(replacement["find"], replacement["replace"])
    end
    updated_body
  end

  def update_draft(edition, updated_body)
    AuditTrail.acting_as(robot_user) do
      edition.update!(
        minor_change: true,
        body: updated_body,
      )
      log(
        "Success: performed find-and-replace on edition #{edition.id} and saved the draft.",
      )
    end
  end

  def create_and_publish_draft(edition, updated_body)
    AuditTrail.acting_as(robot_user) do
      draft_edition = edition.create_draft(robot_user)
      draft_edition.update!(minor_change: true, body: updated_body)
      edition_publisher = Whitehall.edition_services.force_publisher(
        draft_edition,
        user: robot_user,
        remark: "Automatically republished content with some body changes",
      )
      edition_publisher.perform!
      log("Success: performed find-and-replace on edition #{edition.id}, saving and publishing a new edition #{draft_edition.id}.")
    end
  end

  def robot_user
    User.find_by(name: "Scheduled Publishing Robot", uid: nil)
  end
end
