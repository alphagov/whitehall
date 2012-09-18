FactoryGirl.define do
  factory :edition_organisation_image_data do
    file { File.open(File.join(Rails.root, 'test', 'fixtures', 'portas-review.jpg')) }
  end
end