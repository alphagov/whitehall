class MinisterialRoleSearchIndexObserver < ActiveRecord::Observer
  observe :person, :organisation, :role_appointment, :organisation_role

  class << self
    attr_accessor :disabled
  end

  def self.while_disabled
    original_disabled = disabled
    begin
      self.disabled = true
      yield
    ensure
      self.disabled = original_disabled
    end
  end

  def after_save(record)
    reindex_ministerial_roles
  end

  def after_destroy(record)
    reindex_ministerial_roles
  end

  private

  def reindex_ministerial_roles
    unless self.class.disabled
      MinisterialRole.reindex_all
    end
  end
end
