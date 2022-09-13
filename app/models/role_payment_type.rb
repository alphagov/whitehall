class RolePaymentType
  include ActiveRecordLikeInterface

  attr_accessor :id, :name

  Unpaied = create!(id: 1, name: "Unpaid")
  ParliamentarySecretary = create!(id: 2, name: "Paid as a Parliamentary Secretary")
  Whip = create!(id: 3, name: "Paid as a whip")
  Consultant = create!(id: 4, name: "Paid as a consultant")
end
