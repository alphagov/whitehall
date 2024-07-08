FactoryBot.define do
  factory :content_block_document, class: "ContentObjectStore::ContentBlockDocument" do
    sequence(:content_id) { SecureRandom.uuid }
    title { "Title" }
    block_type { "email_address" }
    created_at { Time.zone.now.utc }
    updated_at { Time.zone.now.utc }
  end
end
