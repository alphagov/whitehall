FactoryBot.define do
  factory :default_news_organisation_image_data do
    file { File.open(Rails.root.join('test', 'fixtures', 'minister-of-funk.960x640.jpg')) }
  end
end
