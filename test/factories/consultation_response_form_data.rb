FactoryBot.define do
  factory :consultation_response_form_data do
    file { File.open(File.join(Rails.root, 'test', 'fixtures', 'two-pages.pdf')) }
  end
end
