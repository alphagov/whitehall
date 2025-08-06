module Edition::LimitedAccess
  extend ActiveSupport::Concern

  included do
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
    self[:access_limited]
  end

  delegate :access_limited_by_default?, to: :class

  def set_access_limited
    if new_record? && access_limited.nil?
      self.access_limited = access_limited_by_default?
    end
  end

  def accessible_to?(user)
    user.present? && Whitehall::Authority::Enforcer.new(user, self).can?(:see)
  end
end
