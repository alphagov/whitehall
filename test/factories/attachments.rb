FactoryBot.define do
  sequence(:attachment_ordering)

  trait :abstract_attachment do
    attachable { build :policy_group }
  end

  factory :attachment, class: FileAttachment, traits: [:abstract_attachment] do
    sequence(:title) { |index| "file-attachment-title-#{index}" }
    accessible { false }

    transient do
      file { File.open(Rails.root.join("test/fixtures/greenpaper.pdf")) }
    end

    trait(:pdf) do
      after(:build) do |attachment, evaluator|
        attachment.attachment_data ||= build(:attachment_data, file: evaluator.file, content_type: AttachmentUploader::PDF_CONTENT_TYPE, attachable: attachment.attachable)
      end
    end

    trait(:csv) do
      transient do
        file { File.open(Rails.root.join("test/fixtures/sample.csv")) }
      end

      after(:build) do |attachment, evaluator|
        attachment.attachment_data ||= build(:attachment_data_for_csv, file: evaluator.file, attachable: attachment.attachable)
      end
    end

    trait(:with_no_assets) do
      after(:build) do |attachment, evaluator|
        attachment.attachment_data ||= build(:attachment_data_with_no_assets, file: evaluator.file, attachable: attachment.attachable)
      end
    end
  end

  factory :file_attachment, parent: :attachment, traits: [:pdf]
  factory :csv_attachment, parent: :attachment, traits: [:csv]
  factory :file_attachment_with_no_assets, parent: :attachment, traits: [:with_no_assets]

  factory :html_attachment do
    sequence(:title) { |index| "html-attachment-title-#{index}" }

    transient do
      body { "Attachment body" }
      manually_numbered_headings { false }
    end

    attachable { build :edition }

    # body and numbering method boolean can be passed directly into the factory
    # and is automatically set on the internal GovspeakContent instance.
    after :build do |attachment, evaluator|
      attachment
        .build_govspeak_content(
          body: evaluator.body,
          manually_numbered_headings: evaluator.manually_numbered_headings,
        )
    end
  end

  factory :external_attachment, traits: [:abstract_attachment] do
    sequence(:title) { |index| "external-attachment-title-#{index}" }
    external_url { "http://www.google.com" }
  end
end
