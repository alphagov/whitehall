module Edition::LimitedAccess
  extend ActiveSupport::Concern

  included do
    enum :access_limited, { disabled: 0, organisations: 1, named_users: 2 }
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
    organisations? || named_users?
  end

  delegate :access_limited_by_default?, to: :class

  def access_limited=(value)
    @_access_limited_explicitly_set = true
    super
  end

  def set_access_limited
    return unless new_record?
    return if @_access_limited_explicitly_set

    self.access_limited = access_limited_by_default? ? :organisations : :disabled
    @_access_limited_explicitly_set = false
  end

  def accessible_to?(user)
    user.present? && Whitehall::Authority::Enforcer.new(user, self).can?(:see)
  end
end
