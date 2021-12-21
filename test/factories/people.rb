FactoryBot.define do
  factory :person, traits: [:translated] do
    sequence(:forename) { |index| "George #{index}" }
  end

  factory :pm, parent: :person do
    slug { "boris-johnson" }
  end
end
