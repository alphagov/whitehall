class Speech < Document
  belongs_to :role_appointment

  validates :role_appointment, :delivered_on, :location, presence: true
end