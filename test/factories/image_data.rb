FactoryGirl.define do
  factory :image_data do
    file { File.open(File.join(Rails.root, 'test', 'fixtures', 'minister-of-funk.960x640.jpg')) }
  end
end