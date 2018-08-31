FactoryBot.define do
  factory :historical_account do
    association :person
    summary { "Some summary text" }
    body { "Some body text" }
    political_parties { [PoliticalParty::Labour] }

    after(:build) do |account|
      unless account.roles.present?
        account.roles << build(:historic_role_appointment, person: account.person).role
      end
    end
  end
end
