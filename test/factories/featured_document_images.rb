FactoryGirl.define do
  factory :featured_document_image do
    image { File.open(File.join(Rails.root, 'test', 'fixtures', 'portas-review.jpg')) }
  end
end