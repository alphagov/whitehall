require "active_record_like_interface"

class PoliticalParty
  include ActiveRecordLikeInterface
  attr_accessor :id, :name, :membership

  Conservative      = create(id: 1, name: "Conservative", membership: "Conservative")
  Labour            = create(id: 2, name: "Labour", membership: "Labour")
  LiberalDemocrats  = create(id: 3, name: "Liberal Democrats", membership: "Liberal Democrat")
  Tories            = create(id: 4, name: "Tories", membership: "Tory")
  Whigs             = create(id: 5, name: "Whigs", membership: "Whig")
  Liberal           = create(id: 6, name: "Liberal", membership: "Liberal")
end
