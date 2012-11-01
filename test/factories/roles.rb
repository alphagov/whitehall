FactoryGirl.define do
  factory :role, parent: :role_without_organisations do
    after :build do |role, evaluator|
      role.organisations = [FactoryGirl.build(:organisation)] unless evaluator.organisations.any?
    end
  end

  factory :role_without_organisations, class: Role do
    name "role-name"
    type ""
  end

end