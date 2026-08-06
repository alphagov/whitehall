class EditionPublisher < EditionService
  def failure_reason
    @failure_reason ||= failure_reasons.first
  end

  def failure_reasons
    return @failure_reasons if @failure_reasons

    reasons = []
    reasons << "This edition is invalid: #{edition.errors.full_messages.to_sentence}" unless edition.valid?(:publish)
    reasons << "An edition that is #{edition.current_state} cannot be #{past_participle}" unless can_transition?
    reasons << "Scheduled editions cannot be published. This edition is scheduled for publication on #{edition.scheduled_publication}" if scheduled_for_publication?
    reasons.concat(edition.invalid_tab_messages)

    @failure_reasons = reasons
  end

  def failure_reasons_plaintext
    failure_reasons.map { |reason| ActionController::Base.helpers.strip_tags(reason).gsub(/\s+/, " ") }.join(", ")
  end

  def verb
    "publish"
  end

private

  def prepare_edition
    flag_if_political_content!
    edition.access_limiting = :none
    edition.access_limiting_organisations.clear
    edition.access_limiting_individuals.destroy_all
    edition.auth_bypass_id = nil
    edition.major_change_published_at = Time.zone.now unless edition.minor_change?
    edition.make_public_at(edition.major_change_published_at)
    edition.increment_version_number
  end

  def update_publishing_api!
    should_update_auth_bypass = edition.saved_change_to_auth_bypass_id?
    super
    EditionAuthBypassAssetPropagator.new(edition).propagate if should_update_auth_bypass
  end

  def fire_transition!
    super
    supersede_previous_editions!
    delete_unpublishing!
  end

  def editions_to_supersede
    edition.document.editions
      .where(state: %i[published unpublished])
      .excluding(edition)
  end

  def supersede_previous_editions!
    editions_to_supersede.each do |edition|
      edition.supersede
      edition.save!(validate: false)
    end
  end

  def delete_unpublishing!
    edition.unpublishing.presence&.destroy!
  end

  def scheduled_for_publication?
    # Just using edition.scheduled? misses submitted editions
    edition.scheduled_publication.present?
  end

  def flag_if_political_content!
    return if edition.document.live?

    edition.political = PoliticalContentIdentifier.political?(edition)
  end
end
