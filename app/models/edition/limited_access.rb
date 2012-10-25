module Edition::LimitedAccess
  extend ActiveSupport::Concern

  included do
    before_save ->(record) { record.access_limited = nil unless record.can_limit_access? }
  end

  module InstanceMethods
    def access_limited?
      self.can_limit_access? && read_attribute(:access_limited)
    end

    def accessible_by?(user)
      if access_limited?
        organisations.include?(user.organisation)
      else
        true
      end
    end
  end
end