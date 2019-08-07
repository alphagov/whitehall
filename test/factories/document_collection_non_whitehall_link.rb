FactoryBot.define do
  factory :document_collection_non_whitehall_link do
    content_id { SecureRandom.uuid }
    base_path { "/vat-rates" }
    title { "VAT Rates" }
    publishing_app { "mainstream" }
  end
end
