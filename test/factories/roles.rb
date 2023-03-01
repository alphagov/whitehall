FactoryBot.define do
  factory :role, parent: :role_without_organisations do
    after :build do |role, evaluator|
      role.organisations = [FactoryBot.build(:organisation)] unless evaluator.organisations.any?
    end
  end

  factory :role_without_organisations, class: MinisterialRole, traits: [:translated] do
    sequence(:name) { |index| "role-name-#{index}" }
    role_type { "minister" }
  end

  factory :non_ministerial_role_without_organisations, class: Role, traits: [:translated] do
    sequence(:name) { |index| "role-name-#{index}" }
    type { "permanent_secretary" }
  end

  factory :historic_role, parent: :ministerial_role do
    supports_historical_accounts { true }
  end

  trait :occupied do
    after :create do |role, _|
      role.role_appointments = [FactoryBot.create(:role_appointment)]
    end
  end

  trait :vacant do
    after :create do |role, _|
      role.role_appointments = [FactoryBot.create(:role_appointment, :ended)]
    end
  end

  factory :prime_minister_role, class: MinisterialRole do
    name { "Prime Minister" }
    slug { "prime-minister" }
    role_type { "minister" }
    supports_historical_accounts { true }
  end
end
