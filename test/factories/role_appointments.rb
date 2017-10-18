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

  factory :ambassador_role_appointment, parent: :role_appointment do
    association :role, factory: :ambassador_role
  end

  factory :high_commissioner_role_appointment, parent: :role_appointment do
    association :role, factory: :high_commissioner_role
  end

  factory :governor_role_appointment, parent: :role_appointment do
    association :role, factory: :governor_role
  end

  factory :deputy_head_of_mission_role_appointment, parent: :role_appointment do
    association :role, factory: :deputy_head_of_mission_role
  end

  factory :historic_role_appointment, parent: :role_appointment do
    association :role, factory: :historic_role
  end

  factory :judge_role_appointment, parent: :role_appointment do
    association :role, factory: :judge_role
  end

  trait :ended do
    ended_at { 1.day.ago }
  end
end
