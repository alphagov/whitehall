class UnpublishReason
  include ActiveRecordLikeInterface

  attr_accessor :id, :name

  PublishedInError  = create(id: 1, name: 'Published in error')
  NoLongerCurrent   = create(id: 2, name: 'No longer current')
  Duplicate         = create(id: 3, name: 'Duplicate of another page')
  Superseded        = create(id: 4, name: 'Superseded by another page')
end
