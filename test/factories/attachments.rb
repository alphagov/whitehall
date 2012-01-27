FactoryGirl.define do
  factory :attachment do
    title "attachment-title"
    file { File.open(File.join(Rails.root, 'test', 'fixtures', 'greenpaper.pdf')) }
  end
end