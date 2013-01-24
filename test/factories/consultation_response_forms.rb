FactoryGirl.define do
  factory :consultation_response_form do
    association :consultation_participation
    title "consultation-response-form-title"
    consultation_response_form_data
  end
end
