FactoryBot.define do
  factory :fatality_notice_casualty, class: FatalityNoticeCasualty do
    sequence(:personal_details) { |i| "personal details #{i}" }
  end
end
