FactoryGirl.define do
  factory :role_appointment do
    role
    person
    started_at 1.day.ago
  end
end