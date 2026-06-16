module Edition::LimitedAccess
  extend ActiveSupport::Concern

  included do
    enum :access_limiting, {
      none: "none",
      organisations: "organisations",
      individuals: "individuals",
    }, prefix: true, default: nil

    after_initialize :set_access_limited
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
end
