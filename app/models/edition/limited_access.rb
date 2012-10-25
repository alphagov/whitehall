module Edition::LimitedAccess
  extend ActiveSupport::Concern

  included do
    before_save ->(record) { record.access_limited = nil unless record.can_limit_access? }
  end

  module ClassMethods
    def accessible_to(user)
      clause = 'access_limited is null OR access_limited=false'
      if user && user.organisation
        where("(#{clause} OR access_limited=false OR exists (
               select * from edition_organisations eo_accessibility_check
               where
                 eo_accessibility_check.edition_id=editions.id
               and eo_accessibility_check.organisation_id=?))", user.organisation.id)
      else
        where("(#{clause})")
      end
    end
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