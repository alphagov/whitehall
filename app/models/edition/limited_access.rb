module Edition::LimitedAccess
  extend ActiveSupport::Concern

  included do
    before_save ->(record) { record.access_limited = nil unless record.can_limit_access? }
  end

  module ClassMethods
    def accessible_to(user)
      clauses = ['access_limited is null OR access_limited=false']
      binds = {}
      if user && user.organisation
        clauses << "exists (
               select * from edition_organisations eo_accessibility_check
               where
                 eo_accessibility_check.edition_id=editions.id
               and eo_accessibility_check.organisation_id=:organisation_id)"
        binds[:organisation_id] = user.organisation.id
        clauses << "exists (
               select * from edition_authors author_accessibility_check
               where
                 author_accessibility_check.edition_id=editions.id
               and author_accessibility_check.user_id=:user_id)"
        binds[:user_id] = user.id
      end
      where("(#{clauses.join(' OR ')})", binds)
    end
  end

  module InstanceMethods
    def access_limited?
      self.can_limit_access? && read_attribute(:access_limited)
    end

    def accessible_by?(user)
      if access_limited?
        organisations.include?(user.organisation) || authors.include?(user)
      else
        true
      end
    end
  end
end