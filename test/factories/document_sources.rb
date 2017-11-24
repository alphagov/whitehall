FactoryBot.define do
  factory :document_source do
    sequence(:url) { |n| "http://ww#{n}.examaple.com/fancy-document-#{n}.aspx" }
  end
end
