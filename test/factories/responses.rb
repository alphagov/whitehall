FactoryGirl.define do
  factory :response do
    published_on { Date.today }
    sequence :summary do |n|
      "response summary #{n}"
    end
  end
end
