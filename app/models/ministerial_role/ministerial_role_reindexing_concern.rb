module MinisterialRole::MinisterialRoleReindexingConcern
  extend ActiveSupport::Concern

  included do
    after_save :reindex_ministerial_roles
    after_destroy :reindex_ministerial_roles
  end

  def reindex_ministerial_roles
    MinisterialRole.reindex_all
  end
end
