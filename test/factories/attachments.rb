FactoryBot.define do
  sequence(:attachment_ordering)

  trait :abstract_attachment do
    attachable { build :policy_group }
  end

  factory :file_attachment, traits: [:abstract_attachment] do
    sequence(:title) { |index| "file-attachment-title-#{index}" }
    transient do
      file { File.open(Rails.root.join('test', 'fixtures', 'greenpaper.pdf')) }
    end
    after(:build) do |attachment, evaluator|
      attachment.attachment_data ||= build(:attachment_data, file: evaluator.file)
    end
  end

  factory :csv_attachment, parent: :file_attachment do
    transient do
      file { File.open(Rails.root.join('test', 'fixtures', 'sample.csv')) }
    end
  end

  factory :html_attachment do
    sequence(:title) { |index| "html-attachment-title-#{index}" }

    transient do
      body "Attachment body"
      manually_numbered_headings false
    end

    attachable { build :edition }

    # body and numbering method boolean can be passed directly into the factory
    # and is automatically set on the internal GovspeakContent instance.
    after :build do |attachment, evaluator|
      attachment.build_govspeak_content(
                   body: evaluator.body,
                   manually_numbered_headings: evaluator.manually_numbered_headings
                 )
    end
  end

  factory :external_attachment, traits: [:abstract_attachment] do
    sequence(:title) { |index| "external-attachment-title-#{index}" }
    external_url "http://www.google.com"
  end
end
