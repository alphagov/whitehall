class UnpublishingReason
  include ActiveRecordLikeInterface

  attr_accessor :id, :name, :as_sentence

  PUBLISHED_IN_ERROR_ID = 1
  CONSOLIDATED_ID = 4
  WITHDRAWN_ID = 5
  ARCHIVED_ID = 6

  PublishedInError  = create!(id: 1, name: "Published in error", as_sentence: "it was published in error")
  Consolidated      = create!(id: 4, name: "Consolidated into another GOV.UK page", as_sentence: "it has been consolidated into another GOV.UK page")
  Withdrawn         = create!(id: 5, name: "No longer current government policy/activity", as_sentence: "it is no longer current government policy/activity")
  Archived          = create!(id: 6, name: "Archived via National Archives", as_sentence: "it has been archived via National Archives")
end
