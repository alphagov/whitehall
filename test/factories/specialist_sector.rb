FactoryGirl.define do
  factory :specialist_sector do
    trait :invalid do
      # Turn off validation so we can create specialist sector with nil
      # content id
      to_create { |specialist_sector| specialist_sector.save(validate: false) }
      topic_content_id nil
    end
  end
end
