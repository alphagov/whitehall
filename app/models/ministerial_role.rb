class MinisterialRole < Role
  has_many :document_ministerial_roles
  has_many :documents, through: :document_ministerial_roles
  has_many :speeches, through: :current_role_appointments
end