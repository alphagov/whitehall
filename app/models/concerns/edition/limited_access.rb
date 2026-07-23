module Edition::LimitedAccess
  extend ActiveSupport::Concern

  included do
    attr_accessor :current_user_for_validation

    enum :access_limiting, {
      none: "none",
      organisations: "organisations",
      individuals: "individuals",
    }, prefix: true

    has_many :edition_access_limiting_organisations,
             class_name: "AccessLimitingOrganisation",
             dependent: :destroy,
             autosave: true,
             validate: false

    has_many :access_limiting_organisations,
             through: :edition_access_limiting_organisations,
             source: :organisation

    has_many :access_limiting_individuals,
             dependent: :destroy,
             autosave: true,
             validate: false,
             inverse_of: :edition

    after_save :clear_pending_access_limiting_organisation_ids

    validate :access_limiting_organisations_required, if: -> { Flipflop.access_limiting_organisations_ui? && access_limiting_organisations? }
    validate :access_limiting_must_include_current_user_organisation
    validate :access_limiting_must_include_current_user_email
    validate :access_limiting_individual_emails_required, if: -> { Flipflop.access_limiting_individuals_ui? && access_limiting_individuals? }
    validate :access_limiting_individual_emails_valid, if: -> { Flipflop.access_limiting_individuals_ui? && access_limiting_individuals? }
  end

  def access_limited_object
    self
  end

  def access_limited?
    access_limiting_organisations? || access_limiting_individuals?
  end

  # TODO: Remove once nothing reads or writes `access_limited` (drop-column ticket).
  def access_limiting=(value)
    super
    self.access_limited = !access_limiting_none?
  end

  def accessible_to?(user)
    user.present? && Whitehall::Authority::Enforcer.new(user, self).can?(:see)
  end

  def access_limiting_organisation_ids=(new_ids)
    ids = Array(new_ids).reject(&:blank?).map(&:to_i).uniq
    @pending_access_limiting_organisation_ids = ids

    # Manually update the in-memory association to reflect the submitted IDs.
    # This prevents immediate database writes and ensures the form re-renders correctly.
    edition_access_limiting_organisations.each(&:mark_for_destruction)
    ids.each do |org_id|
      edition_access_limiting_organisations.build(organisation_id: org_id)
    end
  end

  def access_limiting_organisation_ids
    if defined?(@pending_access_limiting_organisation_ids)
      return @pending_access_limiting_organisation_ids.dup
    end

    super
  end

  def access_limiting_individual_emails=(value)
    parsed_emails = Array(value)
                      .flat_map { |entry| entry.to_s.split(/[\n,;]+/) }
                      .map { |email| email.strip.downcase }
                      .reject(&:blank?)
                      .uniq

    current_emails = access_limiting_individuals.reject(&:marked_for_destruction?).map { |i| i.email.downcase }

    emails_to_remove = current_emails - parsed_emails
    emails_to_add = parsed_emails - current_emails

    access_limiting_individuals.each do |individual|
      individual.mark_for_destruction if emails_to_remove.include?(individual.email.downcase)
    end

    emails_to_add.each do |email|
      access_limiting_individuals.build(email: email)
    end
  end

  def access_limiting_individual_emails
    access_limiting_individuals
      .reject(&:marked_for_destruction?)
      .map(&:email)
      .join(", ")
  end

private

  def clear_pending_access_limiting_organisation_ids
    remove_instance_variable(:@pending_access_limiting_organisation_ids) if defined?(@pending_access_limiting_organisation_ids)
  end

  def access_limiting_organisations_required
    errors.add(:access_limiting_organisation_ids, "must include at least one organisation") if edition_access_limiting_organisations.reject(&:marked_for_destruction?).empty?
  end

  def access_limiting_must_include_current_user_organisation
    return unless current_user_for_validation.present? && access_limiting_organisations?

    if Flipflop.access_limiting_organisations_ui?
      org_ids = edition_access_limiting_organisations
                  .reject(&:marked_for_destruction?)
                  .map(&:organisation_id)

      if org_ids.any? && org_ids.exclude?(current_user_for_validation.organisation&.id)
        errors.add(:access_limiting_organisation_ids, "must include your own organisation")
      end
    elsif organisation_association_enabled? && edition_organisations.map(&:organisation_id).exclude?(current_user_for_validation.organisation&.id)
      errors.add(:base, "Lead or supporting organisations must include your own organisation")
    end
  end

  def access_limiting_must_include_current_user_email
    return unless current_user_for_validation.present? && Flipflop.access_limiting_individuals_ui? && access_limiting_individuals?

    emails = access_limiting_individuals
               .reject(&:marked_for_destruction?)
               .map { |individual| individual.email.to_s.downcase }

    if emails.any? && emails.exclude?(current_user_for_validation.email.to_s.downcase)
      errors.add(:access_limiting_individual_emails, "must include your own email")
    end
  end

  def access_limiting_individual_emails_required
    errors.add(:access_limiting_individual_emails, "must include at least one email when individual access limiting is enabled") if access_limiting_individuals.reject(&:marked_for_destruction?).empty?
  end

  def access_limiting_individual_emails_valid
    individuals = access_limiting_individuals.reject(&:marked_for_destruction?)

    if individuals.any? { |individual| ValidatesEmailFormatOf.validate_email_format(individual.email.to_s) }
      errors.add(:access_limiting_individual_emails, "must contain valid email addresses")
    end

    emails = individuals.map { |individual| individual.email.to_s.downcase }
    unless emails.all? { |email| User.exists?(["LOWER(email) = ?", email]) }
      errors.add(:access_limiting_individual_emails, "must match an existing Signon user")
    end
  end
end
