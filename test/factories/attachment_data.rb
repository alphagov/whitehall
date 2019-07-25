FactoryBot.define do
  factory :attachment_data do
    file { File.open(Rails.root.join('test', 'fixtures', 'greenpaper.pdf')) }
    uploaded_to_asset_manager_at { Time.zone.now }
  end

  factory :image_attachment_data, parent: :attachment_data do
    file { File.open(Rails.root.join('test', 'fixtures', 'minister-of-funk.960x640.jpg')) }
  end
end
