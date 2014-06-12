FactoryGirl.define do
  factory :board_member_role do
    name "Permanent Secretary"

    after :build do |role, evaluator|
      role.organisations = [FactoryGirl.build(:ministerial_department)] unless evaluator.organisations.any?
    end
  end
end
