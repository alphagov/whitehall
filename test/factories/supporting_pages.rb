FactoryGirl.define do
  factory :supporting_page, class: SupportingPage, parent: :edition do
    title "Something Supportive"
    body "Some supporting information"

    trait(:with_alternative_format_provider) do
    end
  end

  factory :draft_supporting_page, parent: :supporting_page
end
