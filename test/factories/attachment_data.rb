FactoryGirl.define do
  factory :attachment_data do
    file { File.open(File.join(Rails.root, 'test', 'fixtures', 'greenpaper.pdf')) }
  end
end
