FactoryGirl.define do
  factory :file_attachment do
    ignore do
      file { File.open(File.join(Rails.root, 'test', 'fixtures', 'greenpaper.pdf')) }
    end

    sequence(:title) { |index| "file-attachment-title-#{index}" }
    sequence(:ordering)
    after(:build) do |attachment, evaluator|
      attachment.attachment_data ||= build(:attachment_data, file: evaluator.file)
    end
  end

  factory :html_attachment do
    sequence(:title) { |index| "html-attachment-title-#{index}" }
    sequence(:ordering)
    body 'Attachment body'
  end
end
