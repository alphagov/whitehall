class MinisterialRole < Role
  has_many :document_ministerial_roles
  has_many :documents, through: :document_ministerial_roles
  has_many :speeches, through: :current_role_appointments

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