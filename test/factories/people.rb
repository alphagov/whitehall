FactoryBot.define do
  factory :person, traits: [:translated] do
    sequence(:forename) { |index| "George #{index}" }
  end

  factory :pm, parent: :person do
    after :create do |person, _evaluator|
      role = create(:ministerial_role, slug: "prime-minister")
      create(:ministerial_role_appointment, person:, role:)
    end
  end
end
