FactoryBot.define do
  factory :unpublishing do
    unpublishing_reason_id UnpublishingReason::PUBLISHED_IN_ERROR_ID
    edition { create(:published_case_study, state: 'draft', first_published_at: 2.days.ago) }

    after(:build) do |unpublishing|
      unpublishing.document_type = unpublishing.edition.class.name
      unpublishing.slug = unpublishing.edition.slug
    end
  end

  factory :published_in_error_redirect_unpublishing, parent: :unpublishing do
    redirect true
    alternative_url Whitehall.public_root + '/government/another/page'
  end

  factory :published_in_error_no_redirect_unpublishing, parent: :unpublishing do
    redirect false
    explanation "published in error"
    alternative_url Whitehall.public_root + '/government/another/page'
  end

  factory :consolidated_unpublishing, parent: :unpublishing do
    unpublishing_reason_id UnpublishingReason::CONSOLIDATED_ID
    alternative_url Whitehall.public_root + '/government/another/page'
  end

  factory :withdrawn_unpublishing, parent: :unpublishing do
    unpublishing_reason_id UnpublishingReason::WITHDRAWN_ID
    redirect false
    explanation "content was withdrawn"
  end
end
