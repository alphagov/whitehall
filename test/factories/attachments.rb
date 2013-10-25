FactoryGirl.define do
  factory :attachment do
    sequence(:title) { |index| "attachment-title-#{index}" }
    sequence(:ordering)

    ignore do
      file { File.open(File.join(Rails.root, 'test', 'fixtures', 'greenpaper.pdf')) }
    end

    after(:build) do |attachment, evaluator|
      attachment.attachment_data ||= build(:attachment_data, file: evaluator.file)
    end
  end
end
