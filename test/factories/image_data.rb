FactoryGirl.define do
  factory :image_data do
    file { File.open(File.join(Rails.root, 'test', 'fixtures', 'portas-review.jpg')) }
  end
end