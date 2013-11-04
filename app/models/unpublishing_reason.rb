class UnpublishingReason
  include ActiveRecordLikeInterface

  attr_accessor :id, :name, :as_sentence

  PublishedInError  = create(id: 1, name: 'Published in error', as_sentence: 'it was published in error')
  Consolidated      = create(id: 4, name: 'Consolidated into another GOV.UK page', as_sentence: 'it has been consolidated into another GOV.UK page')
  Archived          = create(id: 5, name: 'No longer current government policy/activity', as_sentence: 'it is no longer current government policy/activity')
  # Legacy reasons; no longer available in admin.
  Duplicate         = create(id: 2, name: 'Duplicate of another page', as_sentence: 'it is a duplicate of another page')
  Superseded        = create(id: 3, name: 'Superseded by another page', as_sentence: 'it has been superseded by another page')
end
