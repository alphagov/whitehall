class UnpublishingReason
  include ActiveRecordLikeInterface

  attr_accessor :id, :name, :as_sentence

  PublishedInError  = create(id: 1, name: 'Published in error', as_sentence: 'it was published in error')
  Duplicate         = create(id: 2, name: 'Duplicate of another page', as_sentence: 'is a duplicate of another page')
  Superseded        = create(id: 3, name: 'Superseded by another page', as_sentence: 'has been superseded by another page')
end
