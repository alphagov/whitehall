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
      reminder_sent_at { nil }
    end

    trait(:reminder_sent) do
      review_at { Time.zone.today }
      reminder_sent_at { Time.zone.now }
    end

    trait(:due_but_never_published) do
      review_at { Time.zone.today }
      reminder_sent_at { nil }
      document { create(:document, editions: [build(:draft_edition, first_published_at: nil)]) }
    end

    trait(:not_due_yet) do
      review_at { 1.month.from_now }
      reminder_sent_at { nil }
    end
  end
end
