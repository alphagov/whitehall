FactoryBot.define do
  factory :consultation_response_form do
    transient do
      file { File.open(File.join(Rails.root, 'test', 'fixtures', 'two-pages.pdf')) }
    end
    association :consultation_participation
    title { "consultation-response-form-title" }
    consultation_response_form_data { build(:consultation_response_form_data, file: file) }
  end
end
