FactoryBot.define do
  factory :signon_user, class: "ContentBlockManager::SignonUser" do
    uid { SecureRandom.uuid }
    sequence(:name) { |i| "Someone #{i}" }
    sequence(:email) { |i| "someone-#{i}@example.com" }
    organisation { build(:signon_user_organisation) }

    initialize_with do
      new(
        uid:,
        name:,
        email:,
        organisation:,
      )
    end
  end
end
