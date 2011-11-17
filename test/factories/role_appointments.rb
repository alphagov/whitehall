FactoryGirl.define do
  factory :role_appointment do
    role
    person
    started_at { 1.day.ago }
  end

  factory :ministerial_role_appointment, parent: :role_appointment do
    association :role, factory: :ministerial_role
  end

  factory :board_member_role_appointment, parent: :role_appointment do
    association :role, factory: :board_member_role
  end
end