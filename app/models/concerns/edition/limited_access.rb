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

    after_initialize :set_access_limited
    before_create :clear_access_limiting_organisations_if_not_by_organisations, if: -> { Flipflop.access_limiting_organisations_ui? }
    validate :access_limiting_organisations_required, if: -> { Flipflop.access_limiting_organisations_ui? && access_limiting_organisations? }
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

  def access_limiting_organisations_required
    errors.add(:access_limiting_organisation_ids, "must include at least one organisation when access limiting is enabled") if edition_access_limiting_organisations.empty?
  end

  # This will override the default has_many :through ids setter. The default setter writes
  # through records with edition_id: nil, which causes a NotNullViolation during
  # autosave on new records. Using the direct has_many instead defers all DB writes
  # to when the edition is saved.
  def access_limiting_organisation_ids=(new_organisation_ids)
    edition_access_limiting_organisations.each(&:mark_for_destruction)

    Array(new_organisation_ids).reject(&:blank?).each do |org_id|
      edition_access_limiting_organisations.build(organisation_id: org_id.to_i)
    end
  end

private

  # Prevents org associations from being saved on a new record when the user
  # submits "No access limiting" (e.g. after correcting a failed lockout attempt).
  def clear_access_limiting_organisations_if_not_by_organisations
    edition_access_limiting_organisations.each(&:mark_for_destruction) unless access_limiting_organisations?
  end
end
