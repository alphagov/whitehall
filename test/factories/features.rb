FactoryGirl.define do
  factory :feature do
    document
    image { File.open(File.join(Rails.root, 'test', 'fixtures', 'minister-of-funk.960x640.jpg')) }
    alt_text "An accessible description of the image"
  end
end