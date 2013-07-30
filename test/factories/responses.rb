FactoryGirl.define do
  factory :consultation_outcome  do
    published_on { Date.today }
    sequence :summary do |n|
      "outcome summary #{n}"
    end
  end

  factory :consultation_public_feedback do
    published_on { Date.today }
    sequence :summary do |n|
      "public feedback summary #{n}"
    end
  end
end
