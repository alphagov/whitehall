FactoryGirl.define do
  factory :attachment do
    sequence(:title) { |index| "attachment-title-#{index}" }

    ignore do
      file { File.open(File.join(Rails.root, 'test', 'fixtures', 'greenpaper.pdf')) }
    end
  end

  factory :file_attachment, class: FileAttachment, parent: :attachment do
    after(:build) do |attachment, evaluator|
      attachment.attachment_data ||= build(:attachment_data, file: evaluator.file)
    end
  end

  factory :html_attachment, class: HtmlAttachment, parent: :attachment do
    body 'Attachment body'
  end
end
