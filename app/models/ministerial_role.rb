class MinisterialRole < Role
  include Rails.application.routes.url_helpers

  has_many :document_ministerial_roles
  has_many :documents, through: :document_ministerial_roles
  has_many :speeches, through: :current_role_appointments

  after_save :update_in_search_index
  after_destroy :remove_from_search_index

  def self.cabinet
    name = arel_table[:name]
    where(cabinet_member: true).order(name.not_eq('Prime Minister'), name.not_eq('Deputy Prime Minister')).alphabetical_by_person
  end

  def permanent_secretary
    false
  end
  def permanent_secretary?
    permanent_secretary
  end

  def destroyable?
    super && documents.empty?
  end

  def search_index
    # This should be ministerial_role_path(self), but we can't use that because friendly_id's #to_param returns
    # the old value of the slug (e.g. nil for a new record) if the record is dirty, and apparently the record
    # is still marked as dirty during after_save callbacks.
    link = ministerial_role_path(slug)

    { 'title' => to_s, 'link' => link, 'indexable_content' => current_person_biography, 'format' => 'minister' }
  end

  private

  def update_in_search_index
    Rummageable.index(search_index)
  end

  def remove_from_search_index
    Rummageable.delete(ministerial_role_path(self))
  end
end