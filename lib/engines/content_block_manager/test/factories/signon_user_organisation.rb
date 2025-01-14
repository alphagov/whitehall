FactoryBot.define do
  factory :signon_user_organisation, class: "ContentBlockManager::SignonUser::Organisation" do
    content_id { SecureRandom.uuid }
    sequence(:name) { |i| "organisation #{i}" }
    sequence(:slug) { |i| "organisation-#{i}" }

    initialize_with do
      new(
        content_id:,
        name:,
        slug:,
      )
    end
  end
end
