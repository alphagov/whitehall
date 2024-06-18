FactoryBot.define do
  factory :republishing_event do
    action { "Content item scheduled for republishing" }
    bulk { false }
    reason { "this needs republishing" }
    content_id { "611a6777-1d65-4661-a880-a9314628a14b" }
  end

  trait :bulk do
    bulk { true }
    bulk_content_type { "all_documents" }
    content_id { nil }
  end
end
