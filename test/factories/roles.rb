FactoryBot.define do
  factory :role, parent: :role_without_organisations do
    after :build do |role, evaluator|
      role.organisations = [FactoryBot.build(:organisation)] unless evaluator.organisations.any?
    end
  end

  factory :role_without_organisations, class: MinisterialRole, traits: [:translated] do
    sequence(:name) { |index| "role-name-#{index}" }
    role_type "minister"
  end

  factory :historic_role, parent: :ministerial_role do
    supports_historical_accounts true
  end

  trait :occupied do
    after :build do |role, _|
      role.role_appointments = [FactoryBot.build(:role_appointment)]
    end
  end

  trait :vacant do
    after :build do |role, _|
      role.role_appointments = [FactoryBot.build(:role_appointment, :ended)]
    end
  end
end
