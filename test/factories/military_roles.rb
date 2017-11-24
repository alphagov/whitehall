FactoryBot.define do
  factory :military_role do
    name "Chief of the Air Staff"
    after :build do |role, evaluator|
      role.organisations = [FactoryBot.build(:organisation)] unless evaluator.organisations.any?
    end
  end
end
