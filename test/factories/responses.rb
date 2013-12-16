FactoryGirl.define do
  trait :response do
    consultation
    published_on { Date.today }
  end

  factory :consultation_outcome, traits: [:response] do
    sequence :summary do |n|
      "outcome summary #{n}"
    end
  end

  factory :consultation_public_feedback, traits: [:response] do
    sequence :summary do |n|
      "public feedback summary #{n}"
    end
  end
end
