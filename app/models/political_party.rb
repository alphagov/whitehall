require 'active_record_like_interface'

class PoliticalParty
  include ActiveRecordLikeInterface
  attr_accessor :id, :name, :membership

  Conservatives     = create(id: 1, name: 'Conservatives', membership: 'Conservative')
  Labour            = create(id: 2, name: 'Labour', membership: 'Labour')
  LiberalDemocrats  = create(id: 3, name: 'Liberal Democrats', membership: 'Liberal Democrat')
  Tories            = create(id: 4, name: 'Tories', membership: 'Tory')
  Whigs             = create(id: 5, name: 'Whigs', membership: 'Whig')
end
