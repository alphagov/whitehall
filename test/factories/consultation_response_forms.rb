FactoryGirl.define do
  factory :consultation_response_form do
    association :consultation_participation
    title "consultation-response-form-title"
    file { File.open(File.join(Rails.root, 'test', 'fixtures', 'two-pages.pdf')) }
  end
end
