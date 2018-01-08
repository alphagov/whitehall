# encoding: UTF-8

class RolePaymentType
  include ActiveRecordLikeInterface

  attr_accessor :id, :name

  Unpaied = create(id: 1, name: "Unpaid")
  ParliamentarySecretary = create(id: 2, name: "Paid as a Parliamentary Secretary")
end
