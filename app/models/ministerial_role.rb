class MinisterialRole < Role
  has_many :document_ministerial_roles
  has_many :documents, through: :document_ministerial_roles
  has_many :speeches, through: :current_role_appointments

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
end