FactoryBot.define do
  factory :chief_professional_officer_role do
    name { "Chief Medical Officer" }
    after :build do |role, evaluator|
      role.organisations = [FactoryBot.build(:organisation)] unless evaluator.organisations.any?
    end
  end
end
