FactoryGirl.define do
  sequence(:attachment_ordering)

  factory :file_attachment do
    ignore do
      file { File.open(Rails.root.join('test', 'fixtures', 'greenpaper.pdf')) }
    end
    attachable { build :policy_advisory_group }
    sequence(:title) { |index| "file-attachment-title-#{index}" }
    ordering { generate(:attachment_ordering) }
    after(:build) do |attachment, evaluator|
      attachment.attachment_data ||= build(:attachment_data, file: evaluator.file)
    end
  end

  factory :csv_attachment, parent: :file_attachment do
    attachable { build :policy_advisory_group }
    ignore do
      file { File.open(Rails.root.join('test', 'fixtures', 'sample.csv')) }
    end
  end

  factory :html_attachment do
    attachable { build :policy_advisory_group }
    sequence(:title) { |index| "html-attachment-title-#{index}" }
    ordering { generate(:attachment_ordering) }
    body 'Attachment body'
  end
end
