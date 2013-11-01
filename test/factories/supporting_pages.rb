FactoryGirl.define do
  factory :supporting_page, class: SupportingPage, traits: [:with_alternative_format_provider], parent: :edition do
    title "Something Supportive"
    body "Some supporting information"

    ignore do
      related_policies { [] }
    end

    after(:build) do |supporting_page, evaluator|
      if evaluator.related_policies.any?
        supporting_page.related_policy_ids = evaluator.related_policies.map(&:id)
      else
        supporting_page.related_policy_ids = [create(:published_policy).id]
      end
    end
  end

  factory :draft_supporting_page, parent: :supporting_page
  factory :published_supporting_page, parent: :supporting_page, traits: [:published]
end
