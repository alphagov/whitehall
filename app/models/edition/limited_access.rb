module Edition::LimitedAccess
  extend ActiveSupport::Concern

  included do
    after_initialize :set_access_limited
  end

  module ClassMethods
    def accessible_to(user)
      access_clauses = ['access_limited = false']
      loc_clauses = []
      binds = {}
      if user
        if user.organisation
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
        if user.location_limited?
          loc_clauses << "EXISTS (
                 SELECT 1 FROM edition_world_locations location_accessibility_check
                  WHERE location_accessibility_check.edition_id = editions.id
                    AND location_accessibility_check.world_location_id IN (:user_location_ids))"
          # if the user has no world locations (which shouldn't happen,
          # but you never know) make sure we don't generate 'IN ()' SQL
          # which doesn't do what you expect
          binds[:user_location_ids] = [0, *user.world_location_ids]
        end
      end
      # we want ((access_limited = false or (in_org or is_author)) and (in_loc))
      access_clause = access_clauses.join(' OR ')
      loc_clause = loc_clauses.join(' OR ')
      where_clause = access_clause
      where_clause = "(#{where_clause}) AND (#{loc_clause})" unless loc_clause.blank?
      where(where_clause, binds)
    end

    def access_limited_by_default?
      false
    end
  end

  def access_limited?
    read_attribute(:access_limited)
  end

  def access_limited_by_default?
    self.class.access_limited_by_default?
  end

  def accessible_by?(user)
    return false if user && user.location_limited? && (world_locations & user.world_locations).empty?
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