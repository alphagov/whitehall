FactoryBot.define do
  factory :host_content_update_event do
    author { create(:user) }
    created_at { Time.zone.now }
    content_id { SecureRandom.uuid }
    content_title { "Some title" }

    initialize_with do
      new(author:, created_at:, content_id:, content_title:)
    end
  end
end
