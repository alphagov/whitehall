FactoryGirl.define do
  factory :image do
    association :document, factory: :news_article
    alt_text "An accessible description of the image"
    image_data
  end
end