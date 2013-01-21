module Edition::LimitedAccess
  extend ActiveSupport::Concern

  included do
    after_initialize :set_access_limited
  end

  module ClassMethods
    def accessible_to(user)
      clauses = ['access_limited = false']
      binds = {}
      if user && user.organisation
        clauses << "EXISTS (
               SELECT * FROM edition_organisations eo_accessibility_check
               WHERE
                 eo_accessibility_check.edition_id = editions.id
               AND eo_accessibility_check.organisation_id = :organisation_id)"
        binds[:organisation_id] = user.organisation.id
        clauses << "EXISTS (
               SELECT * FROM edition_authors author_accessibility_check
               WHERE
                 author_accessibility_check.edition_id = editions.id
               AND author_accessibility_check.user_id = :user_id)"
        binds[:user_id] = user.id
      end
      where("(#{clauses.join(' OR ')})", binds)
    end

    def access_limited_by_default?
      false
    end
  end

  module InstanceMethods
    def access_limited?
      read_attribute(:access_limited)
    end

    def access_limited_by_default?
      self.class.access_limited_by_default?
    end

    def accessible_by?(user)
      if access_limited?
        organisations.include?(user.organisation) || authors.include?(user)
      else
        true
      end
    end

    def set_access_limited
      if new_record? && access_limited.nil?
        self.access_limited = self.access_limited_by_default?
      end
    end
  end
end