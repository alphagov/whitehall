FactoryGirl.define do
  factory :unpublishing do
    association :edition, factory: :draft_policy
    unpublishing_reason_id UnpublishingReason::PublishedInError.id
    document_type 'GenericEdition'
    slug 'some-slug-for-an-unpublished-page'
  end
end
