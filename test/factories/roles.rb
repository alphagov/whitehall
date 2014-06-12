FactoryGirl.define do
  factory :role, parent: :role_without_organisations do
    after :build do |role, evaluator|
      role.organisations = [FactoryGirl.build(:organisation)] unless evaluator.organisations.any?
    end
  end

  factory :role_without_organisations, class: Role, traits: [:translated] do
    sequence(:name) { |index| "role-name-#{index}" }
    type ""
  end

  factory :historic_role, parent: :ministerial_role do
    supports_historical_accounts true
  end
end
