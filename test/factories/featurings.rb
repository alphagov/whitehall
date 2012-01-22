FactoryGirl.define do
  factory :featuring do
    image { File.open(File.join(Rails.root, 'test', 'fixtures', 'portas-review.jpg')) }
  end
end