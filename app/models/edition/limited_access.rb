module Edition::LimitedAccess
  extend ActiveSupport::Concern

  included do
    before_save ->(record) { record.access_limited = nil unless record.can_limit_access? }
  end

  module ClassMethods
    def accessible_to(user)
      clauses = ['access_limited IS NULL OR access_limited = false']
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