# encoding: UTF-8

class RolePaymentType
  include ActiveRecordLikeInterface

  attr_accessor :id, :name, :footnote

  Unpaied  = create(id: 1, name: "unpaid", footnote: "*")
  ParliamentarySecretary = create(id: 2, name: "paid as a Parliamentary Secretary", footnote: "†")
end