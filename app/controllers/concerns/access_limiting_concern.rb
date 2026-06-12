module AccessLimitingConcern
  extend ActiveSupport::Concern

  def access_limiting_organisations_valid?
    return true unless Flipflop.access_limiting_organisations_ui?
    return true unless submitted_access_limiting_organisation_ids.empty?
    return true unless @edition.access_limiting_organisations?

    @edition.errors.add(:access_limiting_organisation_ids,
                        "must include at least one organisation when access limiting is enabled")
    false
  end

  def submitted_access_limiting_organisation_ids
    @submitted_access_limiting_organisation_ids ||= Array(edition_params[:access_limiting_organisation_ids]).reject(&:blank?)
  end

  def clear_access_limiting_organisations_unless_organisations_selected
    return unless Flipflop.access_limiting_organisations_ui?

    @edition.access_limiting_organisation_ids = [] unless @edition.access_limiting == "organisations"
  end

  def sync_access_limiting_organisations
    return unless Flipflop.access_limiting_organisations_ui?

    if submitted_access_limiting_organisation_ids.any?
      @edition.access_limiting_organisations = Organisation.where(id: submitted_access_limiting_organisation_ids)
    else
      @edition.edition_access_limiting_organisations.each(&:mark_for_destruction)
    end
  end

  def sync_access_limiting_individuals
    return unless Flipflop.access_limiting_individuals_ui?

    if @edition.access_limiting_individuals? && submitted_individual_emails.any?
      @edition.access_limiting_individuals = submitted_individual_emails.map { |email| AccessLimitingIndividual.new(email:) }
    else
      @edition.access_limiting_individuals.each(&:mark_for_destruction)
    end
  end

  def sync_access_limiting_values
    sync_access_limiting_individuals
    sync_access_limiting_organisations
  end

  def access_limiting_individuals_valid?
    return true unless Flipflop.access_limiting_individuals_ui?
    return true unless @edition.access_limiting_individuals?
    return true if submitted_individual_emails.any?

    @edition.errors.add(:access_limiting_individual_emails,
                        "must include at least one email when individual access limiting is enabled")
    false
  end

  def submitted_individual_emails
    @submitted_individual_emails ||= edition_params[:access_limiting_individual_emails]
                                       .to_s
                                       .split(/[\n,;]+/)
                                       .map { |email| email.strip.downcase }
                                       .reject(&:blank?)
  end
end
