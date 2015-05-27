module DataHygiene
  class PolicyPublicationHistoryWriter
    def initialize(publication, policy, logger = NullLogger.instance)
      @publication = publication
      @policy = policy
      @logger = logger
    end

    def rewrite_history!
      Edition::AuditTrail.acting_as(gds_user) do
        logger.info "Backfilling history for: (#{publication.id}) #{publication.title}"
        store_publication_history_and_reset_first_edition
        store_and_reset_archiving
        reset_first_published_at_to_match_policy
        re_edition_for_major_policy_changes
        replay_publication_history
        re_archive_if_required
        add_an_editorial_remark
        publication.document.reload.change_history.changes.each do |change|
          logger.info "\t(#{change.public_timestamp.to_date.to_s(:uk_short)}) #{change.note}"
        end
      end
    end

  private
    attr_reader :logger, :publication, :policy

    def store_publication_history_and_reset_first_edition
      @publication_history = publication.change_history
      publication.update_column(:change_note, nil)
    end

    def store_and_reset_archiving
      if latest_edition.withdrawn?
        @unpublishing = latest_edition.unpublishing
        latest_edition.update_column(:state, :published)
      end
    end

    def add_an_editorial_remark
      latest_edition.editorial_remarks.create(body: "Rewrote document history to match original policy", author: gds_user)
    end

    def re_archive_if_required
      if @unpublishing
        latest_edition.unpublishing = @unpublishing
        latest_edition.update_column(:state, :archived)
      end
    end

    def reset_first_published_at_to_match_policy
      latest_edition.update_column(:first_published_at, policy.first_published_at)
    end

    def replay_publication_history
      @publication_history.changes.each do |change|
        new_edition = latest_edition.create_draft(gds_user)
        new_edition.minor_change = false
        new_edition.change_note = change.note
        # NOTE: major_change_published_at needs to match that of the publication.
        new_edition.major_change_published_at = publication.major_change_published_at
        new_edition.make_public_at(new_edition.major_change_published_at)
        new_edition.increment_version_number
        new_edition.skip_virus_status_check = true
        new_edition.force_publish!
        # supersede previous editions
        new_edition.document.editions.published.where.not(id: new_edition).each do |edition|
          edition.supersede
          edition.save(validate: false)
        end
      end
    end

    def re_edition_for_major_policy_changes
      policy_major_changes.reverse.each do |change|
        new_edition = latest_edition.create_draft(gds_user)
        new_edition.minor_change = false
        new_edition.change_note = change.note
        # NOTE: major_change_published_at matches that of the policy change.
        new_edition.major_change_published_at = change.public_timestamp
        new_edition.make_public_at(new_edition.major_change_published_at)
        new_edition.increment_version_number
        new_edition.skip_virus_status_check = true
        new_edition.force_publish!
        # supersede previous editions
        new_edition.document.editions.published.where.not(id: new_edition).each do |edition|
          edition.supersede
          edition.save(validate: false)
        end
      end
    end

    def policy_major_changes
      @policy_major_changes ||= policy.change_history.changes.tap do |changes|
        changes.pop
      end
    end

    def latest_edition
      publication.document.reload.latest_edition
    end

    def gds_user
      @gds_user ||= User.find_by!(name: "GDS Inside Government Team")
    end
  end
end
