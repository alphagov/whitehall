FactoryGirl.define do
  factory :document_series, class: DocumentSeries, parent: :edition do
    trait(:with_group) do
      groups { FactoryGirl.build_list :document_series_group, 1 }
    end
  end

  factory :published_document_series, parent: :document_series, traits: [:published]
end
