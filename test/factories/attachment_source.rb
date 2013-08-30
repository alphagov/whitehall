FactoryGirl.define do
  factory :attachment_source do
    sequence(:url) { |index| "http://example.com/attachment-#{index}.pdf" }

    association :attachment, factory: :attachment
  end
end
