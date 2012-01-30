class MinisterialRoleSearchIndexObserver < ActiveRecord::Observer
  observe :person, :organisation, :role_appointment, :organisation_role

  def after_save(record)
    reindex_ministerial_roles
  end

  def after_destroy(record)
    reindex_ministerial_roles
  end

  private

  def reindex_ministerial_roles
    Rummageable.index(MinisterialRole.search_index)
  end
end
