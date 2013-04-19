# encoding: UTF-8

class RolePaymentType
  include ActiveRecordLikeInterface

  attr_accessor :id, :name

  Unpaied  = create(id: 1, name: "unpaid")
  ParliamentarySecretary = create(id: 2, name: "paid as a Parliamentary Secretary")
end