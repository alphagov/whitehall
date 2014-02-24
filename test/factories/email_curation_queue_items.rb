FactoryGirl.define do
  factory :email_curation_queue_item do
    association :edition, factory: :published_edition
    title { edition.try(:title) }
    summary { edition.try(:summary) }
    notification_date { edition.try(:public_timestamp) || Time.zone.now }
  end
end
