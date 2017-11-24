FactoryBot.define do
  factory :judge_role do
    sequence(:name) { |n| "Chief Justice ##{n}" }
    after :build do |role, evaluator|
      role.organisations = [FactoryBot.build(:court)] unless evaluator.organisations.any?
    end
  end
end
