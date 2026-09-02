FactoryBot.define do
  factory :person, traits: [:translated] do
    sequence(:forename) { |index| "George #{index}" }
  end

  trait :with_image do
    image { build(:featured_image_data) }
  end

  factory :person_in_current_role, parent: :person do
    after :create do |person|
      role = create(:role, slug: "test-role")
      create(:role_appointment, role:, person:)
    end
  end

  factory :pm, parent: :person do
    after :create do |person, _evaluator|
      role = create(:ministerial_role, slug: "prime-minister")
      create(:ministerial_role_appointment, person:, role:)
    end
  end
end
