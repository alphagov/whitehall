class UnpublishingReason
  include ActiveRecordLikeInterface

  attr_accessor :id, :name

  PublishedInError  = create(id: 1, name: 'Published in error')
  Duplicate         = create(id: 2, name: 'Duplicate of another page')
  Superseded        = create(id: 3, name: 'Superseded by another page')
end
