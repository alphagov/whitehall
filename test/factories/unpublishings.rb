FactoryGirl.define do
  factory :unpublishing do
    association :edition, factory: :draft_policy
    unpublishing_reason_id UnpublishingReason::PublishedInError.id
    slug 'some-slug-for-an-unpublished-page'
    document_type Policy

    after(:build) do |unpublishing|
      unpublishing.document_type = unpublishing.edition.class.name
    end
  end
end
