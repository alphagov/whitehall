module Edition::LimitedAccess
  extend ActiveSupport::Concern

  included do
    enum :access_limiting, {
      none: "none",
      organisations: "organisations",
      individuals: "individuals",
    }, prefix: true, default: nil

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

    after_initialize :set_access_limited
    validate :access_limiting_organisations_required, if: -> { Flipflop.access_limiting_organisations_ui? && access_limiting_organisations? }
    validate :access_limiting_individual_emails_required, if: -> { Flipflop.access_limiting_individuals_ui? && access_limiting_individuals? }
    validate :access_limiting_individual_emails_format, if: -> { Flipflop.access_limiting_individuals_ui? && access_limiting_individuals? }
  end

  module ClassMethods
    def access_limited_by_default?
      false
    end
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

  delegate :access_limited_by_default?, to: :class

  def set_access_limited
    return unless new_record? && access_limiting.nil?

    self.access_limiting = access_limited_by_default? ? :organisations : :none
  end

  def accessible_to?(user)
    user.present? && Whitehall::Authority::Enforcer.new(user, self).can?(:see)
  end

  def access_limiting_individual_emails
    access_limiting_individuals
      .reject(&:marked_for_destruction?)
      .map(&:email)
      .join(", ")
  end

  def access_limiting_individual_emails=(value)
    parsed_emails = value.to_s
                         .split(/[\n,;]+/)
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

  def access_limiting_organisations_required
    errors.add(:access_limiting_organisation_ids, "must include at least one organisation when access limiting is enabled") if access_limiting_organisations.empty?
  end

  def access_limiting_individual_emails_required
    errors.add(:access_limiting_individual_emails, "must include at least one email when individual access limiting is enabled") if access_limiting_individuals.empty?
  end

  def access_limiting_individual_emails_format
    invalid = access_limiting_individuals
                .reject(&:marked_for_destruction?)
                .reject { |individual| individual.email.to_s.match?(URI::MailTo::EMAIL_REGEXP) }

    errors.add(:access_limiting_individual_emails, "must contain valid email addresses") if invalid.any?
  end
end
