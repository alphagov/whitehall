class MinisterialRole < Role
  include Searchable
  include Rails.application.routes.url_helpers

  has_many :edition_ministerial_roles
  has_many :editions, through: :edition_ministerial_roles
  has_many :speeches, through: :current_role_appointments

  searchable title: :to_s, link: :search_link, content: :current_person_biography, format: 'minister'

  def self.cabinet
    where(cabinet_member: true).alphabetical_by_person
  end

  def permanent_secretary
    false
  end

  def permanent_secretary?
    permanent_secretary
  end

  def ministerial?
    true
  end

  def destroyable?
    super && editions.empty?
  end

  def search_link
    # This should be ministerial_role_path(self), but we can't use that because friendly_id's #to_param returns
    # the old value of the slug (e.g. nil for a new record) if the record is dirty, and apparently the record
    # is still marked as dirty during after_save callbacks.
    ministerial_role_path(slug)
  end
end