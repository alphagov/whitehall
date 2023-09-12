FactoryBot.define do
  factory :review_reminder do
    creator
    document { create(:document, editions: [build(:published_edition)]) }

    sequence :email_address do |n|
      "creator-#{n}@example.com"
    end

    review_at { Time.zone.now + 1.day }

    trait(:reminder_due) do
      review_at { Time.zone.today }
      # Attempting to set review_at to today usually causes a validation error, because review date should be set to a future date
      to_create { |instance| instance.save(validate: false) }
    end

    trait(:reminder_sent) do
      reminder_sent_at { Time.zone.now }
    end

    trait(:document_never_published) do
      document { create(:document, editions: [build(:draft_edition, first_published_at: nil)]) }
    end

    trait(:not_due_yet) do
      review_at { 1.month.from_now }
    end
  end
end
