module Edition::LimitedAccess
  extend ActiveSupport::Concern

  included do
    after_initialize :set_access_limited
  end

  module ClassMethods
    def accessible_to(user)
      access_clauses = ["access_limited = false"]
      binds = {}
      if user&.organisation
        access_clauses << "EXISTS (
                 SELECT * FROM edition_organisations eo_accessibility_check
                 WHERE
                   eo_accessibility_check.edition_id = editions.id
                 AND eo_accessibility_check.organisation_id = :organisation_id)"
        binds[:organisation_id] = user.organisation.id
        access_clauses << "EXISTS (
                 SELECT * FROM edition_authors author_accessibility_check
                 WHERE
                   author_accessibility_check.edition_id = editions.id
                 AND author_accessibility_check.user_id = :user_id)"
        binds[:user_id] = user.id
      end
      # we want ((access_limited = false or (in_org or is_author)))
      access_clause = access_clauses.join(" OR ")
      where(access_clause, binds)
    end

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
    user.present? && self.class.accessible_to(user).where(id:).any?
  end
end
