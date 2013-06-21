FactoryGirl.define do
  factory :attachment_data do
    file { File.open(File.join(Rails.root, 'test', 'fixtures', 'greenpaper.pdf')) }
  end

  factory :image_attachment_data, parent: :attachment_data do
      file { File.open(File.join(Rails.root, 'test', 'fixtures', 'minister-of-funk.960x640.jpg')) }
  end
end
