module Edition::LimitedAccess
  extend ActiveSupport::Concern

  included do
    enum :access_limiting, {
      none: "none",
      organisations: "organisations",
      individuals: "individuals",
    }, prefix: true

    after_initialize :set_access_limited
    validate :access_limiting_organisations_required,
             if: -> { validate_access_limiting_organisations? }
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
    return if access_limited_by_default?.nil?

    if new_record? && access_limited_by_default? && access_limiting_none?
      self.access_limiting = :organisations
    end
  end

  def prefill_default_access_limiting_organisations
    return unless Flipflop.access_limiting_organisations_ui?
    return unless access_limited_by_default? && access_limiting_organisations.empty?

    self.access_limiting_organisations = lead_organisations
  end

  def accessible_to?(user)
    user.present? && Whitehall::Authority::Enforcer.new(user, self).can?(:see)
  end

private

  def validate_access_limiting_organisations?
    Flipflop.access_limiting_organisations_ui? && access_limited?
  end

  def access_limiting_organisations_required
    if access_limiting_organisations? && edition_access_limiting_organisations.empty?
      errors.add(:access_limiting_organisation_ids,
                 "must include at least one organisation when access limiting is enabled")
    end
  end
end
