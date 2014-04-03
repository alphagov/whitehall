FactoryGirl.define do
  sequence(:attachment_ordering)

  trait :abstract_attachment do
    attachable { build :policy_group }
  end

  factory :file_attachment, traits: [:abstract_attachment] do
    sequence(:title) { |index| "file-attachment-title-#{index}" }
    ignore do
      file { File.open(Rails.root.join('test', 'fixtures', 'greenpaper.pdf')) }
    end
    after(:build) do |attachment, evaluator|
      attachment.attachment_data ||= build(:attachment_data, file: evaluator.file)
    end
  end

  factory :csv_attachment, parent: :file_attachment do
    ignore do
      file { File.open(Rails.root.join('test', 'fixtures', 'sample.csv')) }
    end
  end

  factory :html_attachment, traits: [:abstract_attachment] do
    sequence(:title) { |index| "html-attachment-title-#{index}" }
    body 'Attachment body'
  end
end
