FactoryBot.define do
  factory :consultation_response_form_data do
    file { File.open(Rails.root.join('test', 'fixtures', 'two-pages.pdf')) }
  end
end
