FactoryBot.define do
  factory :feature do
    document
    image { image_fixture_file }
    alt_text "An accessible description of the image"
  end
end
